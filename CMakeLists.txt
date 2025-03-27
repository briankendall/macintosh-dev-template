
cmake_minimum_required(VERSION 3.12)
set(CMAKE_CXX_STANDARD 98)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
add_definitions(-DMAC_C -DSHORT_DOUBLE_OK=0)

project(DemoProject C ASM)

# Add your own source files here:

add_application(
    DemoProject
    main.c
    resources.r
    
    logging/logging.c
)


target_include_directories(DemoProject PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(DemoProject PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/logging)

target_link_libraries(DemoProject "-lm")
target_link_libraries(DemoProject ${CMAKE_CURRENT_SOURCE_DIR}/logging/mini-vmac/libClipOut.a)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-stringop-overflow -std=gnu90 -Ofast \
-Werror=declaration-after-statement -Werror=pointer-sign -Wunused-variable -Werror=implicit-function-declaration")

# Enable -ffunction-sections and -gc-sections to make the app as small as possible
# On 68K, also enable --mac-single to build it as a single-segment app (so that this code path doesn't rot)
set_target_properties(DemoProject PROPERTIES COMPILE_OPTIONS -ffunction-sections)
if(CMAKE_SYSTEM_NAME MATCHES Retro68)
    set_target_properties(DemoProject PROPERTIES LINK_FLAGS "-Wl,-gc-sections -Wl,--mac-single")

else()
    set_target_properties(DemoProject PROPERTIES LINK_FLAGS "-Wl,-gc-sections")
endif()


set(SCRIPTS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/scripts)

# Make sure disk image is unmounted:
add_custom_target(check_command ALL
    COMMAND ${SCRIPTS_DIR}/check-and-reset-disk-image.sh ${PROJECT_NAME}
    COMMENT "Checking disk image lock"
    VERBATIM
)
add_dependencies(${PROJECT_NAME}_APPL check_command)


if(DEFINED ENV{MACINTOSH_FTP_STAGING_PATH})
    # Copy built app to FTP staging directory:
    add_custom_command(TARGET ${PROJECT_NAME}_APPL POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.bin" "$ENV{MACINTOSH_FTP_STAGING_PATH}/${PROJECT_NAME}"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Copying built app to staging"
    )
else()
    message("Note: MACINTOSH_FTP_STAGING_PATH not defined, will not copy built app to FTP directory")
endif()


# Define IP address used for UDP-based logging
if(NOT DEFINED ENV{MACINTOSH_LOGGING_LOCAL_IP})
    add_definitions(-DNO_UDP_LOGGING)
else()
    set(MACINTOSH_LOGGING_LOCAL_IP $ENV{MACINTOSH_LOGGING_LOCAL_IP})
    string(REPLACE "." ";" IP_COMPONENTS ${MACINTOSH_LOGGING_LOCAL_IP})
    list(GET IP_COMPONENTS 0 IP_PART1)
    list(GET IP_COMPONENTS 1 IP_PART2)
    list(GET IP_COMPONENTS 2 IP_PART3)
    list(GET IP_COMPONENTS 3 IP_PART4)
    add_definitions(
        -DLOGGING_IP_1=${IP_PART1}
        -DLOGGING_IP_2=${IP_PART2}
        -DLOGGING_IP_3=${IP_PART3}
        -DLOGGING_IP_4=${IP_PART4}
    )
endif()

# So we can get at the project name in tasks.json:
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/ProjectName.txt" "${PROJECT_NAME}")
