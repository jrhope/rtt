dnl Autoconf macros use the AC_ prefix, Automake macros use
dnl the AM_ prefix. Our extensions use the ACX_ prefix when
dnl they are general enough to be used outside of the project.
dnl The OROCOS_ prefix is used for Orocos specific macros.
dnl
dnl 

m4_define([OROCOS_BOOSTPKG],[
AC_LANG_CPLUSPLUS
# Check for boost
AC_CHECK_HEADERS([boost/call_traits.hpp],
[],
[
AC_MSG_ERROR([

Could not find Boost headers. Please install Boost.

You can find Boost at http://www.boost.org/
or if you are a Debian GNU/Linux user, just do:

apt-get install libboost-dev libboost-graph-dev

RedHat and others may call these boost-devel or libboost-devel.

and be sure to rerun bootstrap.sh in the main directory,
so that the package management system can detect the installation.
])
])
AC_LANG_C
])





dnl ACX_VERSION(MAJOR-VERSION,MINOR-VERSION,MICRO-VERSION,BUILD-NUMBER)
dnl Define the version number of the package
dnl Format: MAJOR.MINOR.MICRO-BUILD
dnl Written in M4 because AC_INIT arguments must be static but may
dnl use M4 processing.
m4_define([ACX_VERSION],[
 define([acx_major_version],[$1])
 define([acx_minor_version],[$2])
 define([acx_micro_version],[$3])
 define([acx_version],[acx_major_version.acx_minor_version.acx_micro_version])
]) # ACX_VERSION






dnl ACX_VERSION_POST()
dnl Post init of Autoconf version number stuff
m4_define([ACX_VERSION_POST],[
 MAJOR_VERSION=acx_major_version
 MINOR_VERSION=acx_minor_version
 MICRO_VERSION=acx_micro_version
 DATE=`date +"%Y%m%d_%k%M"`
dnl BUILD=$(svn info packages |grep Revision | sed -e's/Revision: //')
dnl VERSION=acx_version-$BUILD
 VERSION=acx_version
 PACKAGE_VERSION=$VERSION
 AC_SUBST(MAJOR_VERSION)
 AC_SUBST(MINOR_VERSION)
 AC_SUBST(MICRO_VERSION)
 AC_SUBST(VERSION)
 AC_SUBST(PACKAGE_VERSION)
 AC_SUBST(DATE)
 AC_SUBST(BUILD)
]) # ACX_VERSION_POST





dnl ACX_ARG_DEBUG
dnl Flag to choose to enable debugging information
m4_define([ACX_ARG_DEBUG],[
 AC_ARG_ENABLE(debug,
  [AC_HELP_STRING([--enable-debug],[Build debugging information])],
  [ DEBUG=1
  ],
  [ DEBUG=0]
 )
 if test x$DEBUG = x1; then
  #ACX_CXXFLAGS="$ACX_CXXFLAGS -g -O0 ";
  #ACX_CFLAGS="$ACX_CFLAGS -g -O0 ";
  #i did this to get the order -O2 -O0 right
  CFLAGS="$CFLAGS -g -O0"
  CXXFLAGS="$CXXFLAGS -g -O0"
 fi
]) # ACX_ARG_DEBUG





dnl AC_PROG_INSURE
dnl Flag to choose to use Insure++
m4_define([AC_PROG_INSURE],[
# Insure++ is a proriatary code checker/prober
AC_ARG_ENABLE(insure,
 [AC_HELP_STRING([--enable-insure],[Compile with Insure++])],
 [
  AC_CHECK_PROG(insure,insure,insure,no)
  if test "x$insure" = "xinsure"; then
   if test -z $CXX; then
    CXX=insure
   fi;
   if test -z $CC; then
    CC=insure
   fi;
  fi;
 ]
)
]) # AC_PROG_INSURE






dnl AC_PROG_COLORGCC
dnl Check if colorgcc is available and if so,
dnl if use hasn't specified a particular compiler,
dnl use colorgcc.
m4_define([AC_PROG_COLORGCC],[
AC_CHECK_PROG(colorgcc,colorgcc,colorgcc,no)
if test "x$colorgcc" = "xcolorgcc"; then
 if test -z $CXX; then
  CXX=colorgcc
 fi;
 if test -z $CC; then
  CC=colorgcc
 fi;
fi;
])


dnl AC_PROG_DOXYGEN
dnl Check if doxygen is available.
m4_define([AC_PROG_DOXYGEN],[
AC_CHECK_PROG(DOXYGEN,doxygen,doxygen,no)
if test "x$DOXYGEN" = "xno"; then
	DOXYGEN="@echo Not generating docs from source code"
fi
AC_SUBST(DOXYGEN)
])

dnl AC_PROG_DOT
dnl Check if dot is available.
m4_define([AC_PROG_DOT],[
AC_CHECK_PROG(ORODOT,dot,YES,NO)
AC_SUBST(ORODOT)
])





dnl AC_PROG_XMLPROCESSOR
dnl Check if xsltproc is available.
m4_define([AC_PROG_XMLPROCESSOR],[
AC_CHECK_PROG(xml,xsltproc,xsltproc,no)
AM_CONDITIONAL(HAVE_XMLPROCESSOR, test "x$xml" = "xxsltproc")
if test "x$xml" = "xno"; then
XMLPROCESSOR="@echo"
else
XMLPROCESSOR=$xml
fi;
AC_SUBST(XMLPROCESSOR)
])

dnl AC_PROG_DIA
dnl Check if Dia is available.
m4_define([AC_PROG_DIA],[
AC_CHECK_PROG(DIA,dia,dia,no)
dnl if test "x$DIA" = "xno"; then
dnl DIA="@echo Not generating documentation figures"
# AC_MSG_WARN([
# Dia was not found on your system. Using Dia you can generate
# figures for the documentation for the Orocos project.

# You can download Dia from http://www.lysator.liu.se/~alla/dia/ 
# or if you are using Debian GNU/Linux just use: apt-get install dia
# to install Dia.
# ])
dnl fi
dnl AC_MSG_CHECKING( Dia location)
dnl DIA_LOCATION=`which dia`
dnl AC_MSG_RESULT($DIA_LOCATION)

dnl AC_MSG_CHECKING(Dia edition)
dnl DIA_VERSION=`strings $DIA_LOCATION|awk '/Dia-Version:/ {print $2}'`
dnl DIA_VERSION=`echo $DIA_VERSION|cut -d: -f2`
dnl AC_MSG_RESULT($DIA_VERSION)

dnl AC_MSG_CHECKING(Dia's freshness)
dnl DIA_VERSION_MAJOR=`echo $DIA_VERSION|cut -d. -f1`
dnl DIA_VERSION_MINOR=`echo $DIA_VERSION|cut -d. -f2`
dnl let DIA_VERSION_VALUE=${DIA_VERSION_MAJOR}*100+${DIA_VERSION_MINOR}
dnl echo $DIA_VERSION_VALUE
dnl if test $DIA_VERSION_VALUE -lt 90; then
dnl  echo "$0: Dia $DIA_VERSION detected, need 0.90 or newer";
# AC_MSG_RESULT(not ok)
# AC_MSG_WARN([
# Dia found on your system is too old. Using Dia you can generate
# figures for the documentation for the Orocos project.

# You can download Dia from http://www.lysator.liu.se/~alla/dia/ 
# or if you are using Debian GNU/Linux just use: apt-get install dia
# to install Dia.
# ])
dnl DIA="@echo Not generating documentation figures"
dnl else
dnl AC_MSG_RESULT(ok)
dnl fi;
AC_SUBST(DIA)
])

dnl AC_PROG_FOP
dnl Check if Fop is available.
m4_define([AC_PROG_FOP],[
AC_CHECK_PROG(FOP,fop,fop,no)
if test "x$FOP" = "xno"; then
FOP="@echo Not generating PDF documentation"
# AC_MSG_WARN([
# FOP was not found on your system. Using FOP you can generate
# a PDF-file containing the Orocos project documentation.

# FOP is a print formatter driven by XSL formatting objects.

# If you are using Debian GNU/Linux just use: apt-get install libfop-java
# to install FOP.
# ])
fi
AC_SUBST(FOP)
])


dnl ACX_CHECK_DOCBOOK
dnl Check if XSL is available.
m4_define([ACX_DOCBOOK],[
DOCBOOK_XSL_PATH=/usr/share/sgml/docbook/stylesheet/xsl/nwalsh/html/docbook.xsl

AM_CONDITIONAL(HAVE_XMLPROCESSOR, test "x$xml" = "xxsltproc")
XMLPROCESSOR=$xml
AC_SUBST(XMLPROCESSOR)
])





m4_define([ACX_LIB_GCC],[
AC_MSG_CHECKING(for GCC library)
GCCLIB=$(dirname $($CC --print-file-name=libgcc.a) )
AC_SUBST(GCCLIB)
AC_MSG_RESULT($GCCLIB)
])





m4_define([ACX_LIB_STDCXX],[
AC_MSG_CHECKING(for Standard C++ library)
STDCXXLIB=`$CXX -print-file-name=libstdc++.a`
AC_SUBST(STDCXXLIB)
AC_MSG_RESULT($STDCXXLIB)
])






dnl ======================= Preprocessor Flags ===========================

dnl removed by ps







dnl =================== Start of Autoconf Orocos extension macros ====================

dnl OROCOS_INIT(name,major,minor)
m4_define([OROCOS_INIT],[
# Define the version number of the package
# Format: major,minor,micro,build

# use packages version number as build number,
# Since svn uses global version numbers this is actually cool !
#TMPBUILD = $(svn info packages |grep Revision | sed -e's/Revision: //')
# define([svn_version],[$TMPBUILD])

#ACX_VERSION($2,$3,$4,svn_version)

# # Check if Autoconf version is recent enough
# AC_PREREQ(2.53)

# # Include version control information
# AC_REVISION($revision)

# # Initialize Autoconf with package name and version
# AC_INIT($1,acx_version)

# # Tell Autoconf to dump files into the config subdir
# AC_CONFIG_AUX_DIR(config)
# AC_CONFIG_SRCDIR([config.h.in])
# AM_CONFIG_HEADER([config.h])

# dnl Initialize Automake
# AM_INIT_AUTOMAKE(1.6.0)

# ACX_MY_ARGS="$*"

#ACX_VERSION_POST

dnl Default installation path
AC_PREFIX_DEFAULT([/usr/local/orocos])

dnl Work around dirty Autoconf -g -02 bug
if test $CFLAGS; then
 ACX_CFLAGS="$CFLAGS"
fi
if test $CXXFLAGS; then
 ACX_CXXFLAGS="$CXXFLAGS"
fi

AC_PROG_CXX
AC_PROG_CC

CFLAGS=""
CXXFLAGS=""
dnl End work around

dnl Checks for programs.
AC_PROG_AWK
AC_PROG_INSTALL
AC_PROG_RANLIB
AC_PROG_COLORGCC
AC_PROG_INSURE
AC_PROG_XMLPROCESSOR
AC_PROG_DOXYGEN
AC_PROG_DOT
AC_PROG_DIA
AC_PROG_FOP

AC_LANG_CPLUSPLUS
AC_CHECK_HEADER([cppunit/Test.h], [
AM_PATH_CPPUNIT(1.9.6)
],[
AC_MSG_WARN([

Could not find CppUnit headers. The Orocos
Test Suite (ie make check) will not be available.

You can find CppUnit at http://sourceforge.net/projects/cppunit
or if you are a Debian GNU/Linux user, just do:

  apt-get install libcppunit-dev

])
])
AC_LANG_C

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_C_INLINE
dnl AC_TYPE_SIZE_T
dnl AC_HEADER_TIME

dnl Checks for library functions.
dnl AC_FUNC_MALLOC
dnl AC_FUNC_VPRINTF

dnl AC_CHECK_FUNCS([gethrtime gettimeofday])

ACX_LIB_GCC
ACX_LIB_STDCXX

])

m4_define([OROCOS_DEFAULT_FLAGS],[
ACX_CFLAGS="$ACX_CFLAGS $1"
ACX_CXXFLAGS="$ACX_CXXFLAGS $2"
ACX_CXXFLAGS="$ACX_CXXFLAGS $3"
])



m4_define([OROCOS_EXPORT_FLAGS],[
AM_CFLAGS="m4_normalize([$ACX_CFLAGS])"
AM_CXXFLAGS="m4_normalize([$ACX_CXXFLAGS])"
AM_CPPFLAGS="m4_normalize([$ACX_CPPFLAGS])"
AC_SUBST(AM_CFLAGS)
AC_SUBST(AM_CXXFLAGS)
AC_SUBST(AM_CPPFLAGS)
])


m4_define([OROCOS_OUTPUT_INFO],[
echo "
 Configuration:
   Source code location:                ${ECOS_REP}
   Version:                             ${VERSION}
   Target:                              ${ECOS_TARGET}

   Compiler:                            ${CXX}
   C compiler flags:                    ${AM_CFLAGS} ${CFLAGS}
   C++ compiler flags:                  ${AM_CXXFLAGS} ${CXXFLAGS}
   Preprocessor flags:                  ${AM_CPPFLAGS} ${CPPFLAGS}
   Includes:                            ${INCLUDES}
"
echo Run \'make docs\' to generate the documentation.
echo Type \'make new_packages\' to create a package build directory
echo Type \'make configure_packages\' to configure the packages
echo Type \'make all_packages\' to build the configured system
echo
echo Alternatively, you can \'make all\' to use the default configuration.
echo
echo Read the Orocos Installation Manual for detailed instructions
echo   on what these targets mean.
])


m4_define([OROCOS_GENERAL],
[
# Autoconf code equal for all OROCOS packages
OROCOS_INIT($1,$2,$3,$4,$5)

OROCOS_ARG_TARGETOS

dnl add debugging flags at the end
ACX_ARG_DEBUG

CXXFLAGS="$CXXFLAGS $GENERAL_CXXFLAGS "

# Checks for libraries.
dnl AC_CHECK_LIB(pthread,pthread_create)

# Checks for header files.
dnl AC_HEADER_STDC
dnl AC_CHECK_HEADERS([stddef.h string.h sys/time.h unistd.h])

AC_LANG_CPLUSPLUS
# Check for boost
AC_CHECK_HEADERS([boost/call_traits.hpp],
[],
[
AC_MSG_ERROR([

Could not find Boost headers. Please install Boost.

You can find Boost at http://www.boost.org/
or if you are a Debian GNU/Linux user, just do:

apt-get install libboost-dev libboost-graph-dev libboost-signals-dev
])
])
AC_LANG_C

ACX_COMEDI

]) 

dnl Leave empty, use this just for help, pass
dnl the flags to the packages configure script.
m4_define([ACX_COMEDI],[
AC_ARG_WITH(comedi, [AC_HELP_STRING([--with-comedi=/usr/src/comedi/include],[Specify location of comedilib.h ])],
	[ ])
])

m4_define([OROCOS_OUTPUT],[
AC_OUTPUT
OROCOS_OUTPUT_INFO
])


    m4_define([OROCOS_ARG_TARGETOS],[
            AC_MSG_CHECKING(which target OS you want to configure for)

            AC_ARG_WITH(gnulinux,
                [AC_HELP_STRING([--with-gnulinux],[Use userspace GNU/Linux (NOT REALTIME)])],
                [
                AC_MSG_RESULT(GNU/Linux)
		ECOS_TARGET=gnulinux
                ],
                [

                AC_ARG_WITH(rtlinux,
                    [AC_HELP_STRING([--with-rtlinux],[Use RTLinux])],
                    [
                    AC_MSG_RESULT(RTLinux)
		    ECOS_TARGET=rtlinux
    ],
    [
    AC_ARG_WITH(rtai,
            [AC_HELP_STRING([--with-rtai],[Use RTAI (non-LXRT)])],
            [
            AC_MSG_RESULT(RTAI)
	    ECOS_TARGET=rtai
    	    AC_ARG_WITH(linux,
            	[AC_HELP_STRING([--with-linux],[Specify RTAI-patched Linux path (non-LXRT)])],
            	[],[
		AC_MSG_ERROR([
You must specify the location of your patched linux kernel headers when using RTAI.
For example : --with-linux=/usr/src/linux-rtai				
])])
    ],
    [
    AC_ARG_WITH(lxrt,
            [AC_HELP_STRING([--with-lxrt[=/usr/realtime] ],[Use RTAI/LXRT, specify installation directory])],
            [
		if test x"$withval" != x; then RTAI_DIR="$withval"; else RTAI_DIR="/usr/realtime"; fi

            AC_MSG_RESULT(LXRT)
	    ECOS_TARGET=lxrt
	    TARGET_LIBS="-L$RTAI_DIR/lib -llxrt"
	    TARGET_FLAGS="-I$RTAI_DIR/include"
    	    AC_ARG_WITH(linux,
            	[AC_HELP_STRING([--with-linux],[Specify RTAI-patched Linux path (LXRT)])],
            	[],[
		AC_MSG_ERROR([
You must specify the location of your patched linux kernel headers when using RTAI/LXRT.
For example : --with-linux=/usr/src/linux-rtai				
])])
    ],
    [
    AC_ARG_WITH(ecos,
            [AC_HELP_STRING([--with-ecos],[Use eCos])],
            [
            AC_MSG_RESULT(eCos)
	    ECOS_TARGET=ecos
            AC_MSG_ERROR([
                The eCos operating system is not supported yet
                ])
            ],
            [
dnl Default to gnulinux
                AC_MSG_RESULT(GNU/Linux)
                ECOS_TARGET=gnulinux
            ]
            )
    ]
    )
    ]
    )
    ]
    )
    ]
    )
AC_SUBST(ECOS_TARGET)
AC_SUBST(TARGET_LIBS)
AC_SUBST(TARGET_FLAGS)
    ]
    ) # OROCOS_ARG_TARGETOS

dnl Borrowed from CPPUNIT themselves.
dnl
dnl AM_PATH_CPPUNIT(MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
dnl
AC_DEFUN(AM_PATH_CPPUNIT,
[

AC_ARG_WITH(cppunit-prefix,[  --with-cppunit-prefix=PFX   Prefix where CppUnit is installed (optional)],
            cppunit_config_prefix="$withval", cppunit_config_prefix="")
AC_ARG_WITH(cppunit-exec-prefix,[  --with-cppunit-exec-prefix=PFX  Exec prefix where CppUnit is installed (optional)],
            cppunit_config_exec_prefix="$withval", cppunit_config_exec_prefix="")

  if test x$cppunit_config_exec_prefix != x ; then
     cppunit_config_args="$cppunit_config_args --exec-prefix=$cppunit_config_exec_prefix"
     if test x${CPPUNIT_CONFIG+set} != xset ; then
        CPPUNIT_CONFIG=$cppunit_config_exec_prefix/bin/cppunit-config
     fi
  fi
  if test x$cppunit_config_prefix != x ; then
     cppunit_config_args="$cppunit_config_args --prefix=$cppunit_config_prefix"
     if test x${CPPUNIT_CONFIG+set} != xset ; then
        CPPUNIT_CONFIG=$cppunit_config_prefix/bin/cppunit-config
     fi
  fi

  AC_PATH_PROG(CPPUNIT_CONFIG, cppunit-config, no)
  cppunit_version_min=$1

  AC_MSG_CHECKING(for Cppunit - version >= $cppunit_version_min)
  no_cppunit=""
  if test "$CPPUNIT_CONFIG" = "no" ; then
    no_cppunit=yes
  else
    CPPUNIT_CFLAGS=`$CPPUNIT_CONFIG --cflags`
    CPPUNIT_LIBS=`$CPPUNIT_CONFIG --libs`
    cppunit_version=`$CPPUNIT_CONFIG --version`

    cppunit_major_version=`echo $cppunit_version | \
           sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\1/'`
    cppunit_minor_version=`echo $cppunit_version | \
           sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\2/'`
    cppunit_micro_version=`echo $cppunit_version | \
           sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\3/'`

    cppunit_major_min=`echo $cppunit_version_min | \
           sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\1/'`
    cppunit_minor_min=`echo $cppunit_version_min | \
           sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\2/'`
    cppunit_micro_min=`echo $cppunit_version_min | \
           sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\3/'`

    cppunit_version_proper=`expr \
        $cppunit_major_version \> $cppunit_major_min \| \
        $cppunit_major_version \= $cppunit_major_min \& \
        $cppunit_minor_version \> $cppunit_minor_min \| \
        $cppunit_major_version \= $cppunit_major_min \& \
        $cppunit_minor_version \= $cppunit_minor_min \& \
        $cppunit_micro_version \>= $cppunit_micro_min `

    if test "$cppunit_version_proper" = "1" ; then
      AC_MSG_RESULT([$cppunit_major_version.$cppunit_minor_version.$cppunit_micro_version])
    else
      AC_MSG_RESULT(no)
      no_cppunit=yes
    fi
  fi

  if test "x$no_cppunit" = x ; then
     ifelse([$2], , :, [$2])     
  else
     CPPUNIT_CFLAGS=""
     CPPUNIT_LIBS=""
     ifelse([$3], , :, [$3])
  fi

  AC_SUBST(CPPUNIT_CFLAGS)
  AC_SUBST(CPPUNIT_LIBS)
])



