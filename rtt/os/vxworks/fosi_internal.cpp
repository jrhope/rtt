/***************************************************************************
    copyright            : (C) 2014 Jamison Hope
    email                : jrh at theptrgroup dot com

    ***************************************************************************
    *   This library is free software; you can redistribute it and/or         *
    *   modify it under the terms of the GNU General Public                   *
    *   License as published by the Free Software Foundation;                 *
    *   version 2 of the License.                                             *
    *                                                                         *
    *   As a special exception, you may use this file as part of a free       *
    *   software library without restriction.  Specifically, if other files   *
    *   instantiate templates or use macros or inline functions from this     *
    *   file, or you compile this file and link it with other files to        *
    *   produce an executable, this file does not by itself cause the         *
    *   resulting executable to be covered by the GNU General Public          *
    *   License.  This exception does not however invalidate any other        *
    *   reasons why the executable file might be covered by the GNU General   *
    *   Public License.                                                       *
    *                                                                         *
    *   This library is distributed in the hope that it will be useful,       *
    *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
    *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
    *   Lesser General Public License for more details.                       *
    *                                                                         *
    *   You should have received a copy of the GNU General Public             *
    *   License along with this library; if not, write to the Free Software   *
    *   Foundation, Inc., 59 Temple Place,                                    *
    *   Suite 330, Boston, MA  02111-1307  USA                                *
    *                                                                         *
    ***************************************************************************/

#include "../ThreadInterface.hpp"
#include "fosi.h"
#include "../fosi_internal_interface.hpp"
#include "../../Logger.hpp"
#include <cassert>
#include <taskLib.h>

#define INTERNAL_QUAL

namespace RTT
{ namespace os {

    INTERNAL_QUAL int rtos_task_create_main(RTOS_TASK* main_task)
    {
        const char* name = "main";
        main_task->wait_policy = ORO_WAIT_ABS;
        main_task->name = strcpy( (char*)malloc( (strlen(name) + 1) * sizeof(char)), name);
        main_task->thread = pthread_self();
        pthread_attr_init( &(main_task->attr) );
        pthread_attr_setname(&(main_task->attr), main_task->name);
        pthread_attr_setschedpolicy(&(main_task->attr), ORO_SCHED_OTHER);
        struct sched_param sp;
        sp.sched_priority=LowestPriority;
        // Set priority
        // fixme check return value and bail out if necessary
        pthread_attr_setschedparam(&(main_task->attr), &sp);
        main_task->priority = sp.sched_priority;
        main_task->pid = getpid();
        return 0;
    }

    INTERNAL_QUAL int rtos_task_delete_main(RTOS_TASK* main_task)
    {
        pthread_attr_destroy( &(main_task->attr) );
        free(main_task->name);
        return 0;
    }

    struct PosixCookie {
        void* data;
        void* (*wrapper)(void*);
    };

    INTERNAL_QUAL void* rtos_posix_thread_wrapper( void* cookie )
    {
        // store 'self'
        RTOS_TASK* task = ((ThreadInterface*)((PosixCookie*)cookie)->data)->getTask();
        task->pid = taskIdSelf();
        assert( task->pid );

        // call user function
        ((PosixCookie*)cookie)->wrapper( ((PosixCookie*)cookie)->data );
        free(cookie);
        return 0;
    }



    INTERNAL_QUAL int rtos_task_create(RTOS_TASK* task,
                       int priority,
                       unsigned cpu_affinity,
                       const char * name,
                       int sched_type,
                       size_t stack_size,
                       void * (*start_routine)(void *),
                       ThreadInterface* obj)
    {
        int rv; // return value
        task->wait_policy = ORO_WAIT_ABS;
        rtos_task_check_priority( &sched_type, &priority );
        // Save priority internally, since the pthread_attr* calls are broken !
        // we will pick it up later in rtos_task_set_scheduler().
        task->priority = priority;

        PosixCookie* xcookie = (PosixCookie*)malloc( sizeof(PosixCookie) );
        xcookie->data = obj;
        xcookie->wrapper = start_routine;

        // Set name
        if ( strlen(name) == 0 )
            name = "Thread";
        task->name = strcpy( (char*)malloc( (strlen(name) + 1) * sizeof(char)), name);

        if ( (rv = pthread_attr_init(&(task->attr))) != 0 ){
            return rv;
        }
        pthread_attr_setname(&(task->attr), task->name);
        // Set scheduler type (_before_ assigning priorities!)
        if ( (rv = pthread_attr_setschedpolicy(&(task->attr), sched_type)) != 0){
            return rv;
        }
        // Set stack size
        if (stack_size )
            if ( (rv = pthread_attr_setstacksize(&(task->attr), stack_size)) != 0){
                return rv;
            }
        pthread_attr_getschedpolicy(&(task->attr), &rv );
        assert( rv == sched_type );
        /* SCHED_OTHER tasks are always assigned static priority 0, see
           man sched_setscheduler
        */
        struct sched_param sp;
        sp.sched_priority=priority;
        // Set priority
        if ( (rv = pthread_attr_setschedparam(&(task->attr), &sp)) != 0 ){
          return rv;
        }
        rv = pthread_create(&(task->thread), &(task->attr),
                rtos_posix_thread_wrapper, xcookie);

        return rv;
    }

    INTERNAL_QUAL void rtos_task_yield(RTOS_TASK* t) {
        int ret = sched_yield();
        if ( ret != 0)
            perror("rtos_task_yield");
    }

    INTERNAL_QUAL unsigned int rtos_task_get_pid(const RTOS_TASK* task)
    {
        if (task)
            return task->pid;
        return 0;
    }

    INTERNAL_QUAL int rtos_task_is_self(const RTOS_TASK* task) {
        pthread_t self = pthread_self();
        if ( pthread_equal(self, task->thread) == 0 ) // zero means false.
            return 0;
        return 1;
    }

    INTERNAL_QUAL int rtos_task_set_scheduler(RTOS_TASK* task, int sched_type) {
        int policy = -1;
        struct sched_param param;
        // first check the argument
        if ( task && task->thread != 0 && rtos_task_check_scheduler( &sched_type) == -1 )
            return -1;
        // if sched_type is different, the priority must change as well.
        if (pthread_getschedparam(task->thread, &policy, &param) == 0) {
            // now update the priority
            param.sched_priority = task->priority;
            rtos_task_check_priority( &sched_type, &param.sched_priority );
            // write new policy:
            return pthread_setschedparam( task->thread, sched_type, &param);
        }
        return -1;
    }

    INTERNAL_QUAL int rtos_task_get_scheduler(const RTOS_TASK* task) {
        int policy = -1;
        struct sched_param param;
        // first retrieve thread scheduling parameters:
        if ( task && task->thread != 0 && pthread_getschedparam(task->thread, &policy, &param) == 0)
            return policy;
        return -1;
    }

    INTERNAL_QUAL void rtos_task_make_periodic(RTOS_TASK* mytask, NANO_TIME nanosecs )
    {
        // set period
        mytask->period = nanosecs;
        // set next wake-up time.
        mytask->periodMark = ticks2timespec( nano2ticks( rtos_get_time_ns() + nanosecs ) );
    }

    INTERNAL_QUAL void rtos_task_set_period( RTOS_TASK* mytask, NANO_TIME nanosecs )
    {
        rtos_task_make_periodic(mytask, nanosecs);
    }

  INTERNAL_QUAL void rtos_task_set_wait_period_policy( RTOS_TASK* task, int policy )
  {
    task->wait_policy = policy;
  }

    INTERNAL_QUAL int rtos_task_wait_period( RTOS_TASK* task )
    {
        if ( task->period == 0 )
            return 0;

        // record this to detect overrun.
        NANO_TIME now = rtos_get_time_ns();
        NANO_TIME wake= task->periodMark.tv_sec * 1000000000LL + task->periodMark.tv_nsec;

        // inspired by nanosleep man page for this construct:
        while ( clock_nanosleep(CLOCK_REALTIME, TIMER_ABSTIME, &(task->periodMark), NULL) != 0 && errno == EINTR ) {
            errno = 0;
        }

        if (task->wait_policy == ORO_WAIT_ABS)
        {
          // program next period:
          // 1. convert period to timespec
          TIME_SPEC ts = ticks2timespec( nano2ticks( task->period) );
          // 2. Add ts to periodMark (danger: tn guards for overflows!)
          NANO_TIME tn = (task->periodMark.tv_nsec + ts.tv_nsec);
          task->periodMark.tv_nsec = tn % 1000000000LL;
          task->periodMark.tv_sec += ts.tv_sec + tn / 1000000000LL;
        }
        else
        {
          TIME_SPEC ts = ticks2timespec( nano2ticks( task->period) );
          TIME_SPEC now = ticks2timespec( rtos_get_time_ns() );
          NANO_TIME tn = (now.tv_nsec + ts.tv_nsec);
          task->periodMark.tv_nsec = tn % 1000000000LL;
          task->periodMark.tv_sec = ts.tv_sec + now.tv_sec + tn / 1000000000LL;
        }

        return now > wake ? -1 : 0;
    }

    INTERNAL_QUAL void rtos_task_delete(RTOS_TASK* mytask) {
        pthread_join( mytask->thread, 0);
        pthread_attr_destroy( &(mytask->attr) );
        free(mytask->name);
    }

    INTERNAL_QUAL int rtos_task_check_scheduler(int* scheduler)
    {
        if (*scheduler != SCHED_OTHER && *scheduler != SCHED_FIFO && *scheduler != SCHED_RR ) {
            log(Error) << "Unknown scheduler type." <<endlog();
            *scheduler = SCHED_OTHER;
            return -1;
        }
        return 0;
    }

    INTERNAL_QUAL int rtos_task_check_priority(int* scheduler, int* priority)
    {
        int ret = 0;
        // check scheduler first.
        ret = rtos_task_check_scheduler(scheduler);

        // correct priority
        if (*priority < LowestPriority) {
          log(Warning) << "Forcing priority ("<<*priority<<") of thread to "<<LowestPriority<<"."<<endlog();
          *priority = LowestPriority;
          ret = -1;
        } else if (*priority > HighestPriority) {
          log(Warning) << "Forcing priority ("<<*priority<<") of thread to "<<HighestPriority<<"."<<endlog();
          *priority = HighestPriority;
          ret = -1;
        }

        return ret;
    }

    INTERNAL_QUAL int rtos_task_set_priority(RTOS_TASK * task, int priority)
    {
        int policy = 0;
        struct sched_param param;
        // first retrieve thread scheduling parameters:
        if( task && task->thread != 0 && pthread_getschedparam(task->thread, &policy, &param) == 0) {
            if ( rtos_task_check_priority( &policy, &priority ) != 0 )
                return -1;
            param.sched_priority = priority;
            task->priority = priority; // store for set_scheduler
            // write new policy:
            return pthread_setschedparam( task->thread, policy, &param);
        }
        return -1;
    }

    INTERNAL_QUAL int rtos_task_get_priority(const RTOS_TASK *task)
    {
        // if sched_other, return the 'virtual' priority
        int policy = 0;
        struct sched_param param;
        // first retrieve thread scheduling parameters:
        if ( task == 0 )
            return -1;
        if ( task->thread == 0 || pthread_getschedparam(task->thread, &policy, &param) != 0)
            return task->priority;
        return param.sched_priority;
    }

    INTERNAL_QUAL int rtos_task_set_cpu_affinity(RTOS_TASK * task, unsigned cpu_affinity)
    {
        return -1;
    }

    INTERNAL_QUAL unsigned rtos_task_get_cpu_affinity(const RTOS_TASK *task)
    {
        return ~0;
    }

    INTERNAL_QUAL const char * rtos_task_get_name(const RTOS_TASK* task)
    {
        return task->name;
    }

  }
}
#undef INTERNAL_QUAL
