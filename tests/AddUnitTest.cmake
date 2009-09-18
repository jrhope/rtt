MACRO( ADD_UNIT_TEST TEST_NAME)

    SET(LIBS ${ARGN})      
    ADD_EXECUTABLE( ${TEST_NAME} test-runner.cpp ${TEST_NAME}.cpp )
    TARGET_LINK_LIBRARIES( ${TEST_NAME} orocos-rtt-dynamic_${OROCOS_TARGET} 
        ${LIBS} ${TEST_LIBRARIES})
    SET_TARGET_PROPERTIES( ${TEST_NAME} PROPERTIES 
        COMPILE_FLAGS "${CMAKE_CXX_FLAGS_ADD}" 
        LINK_FLAGS "${CMAKE_LD_FLAGS_ADD}"
        COMPILE_DEFINITIONS "${OROCOS-RTT_DEFINITIONS}" )
    ADD_TEST( ${TEST_NAME} ${TEST_NAME})
ENDMACRO(ADD_UNIT_TEST)

