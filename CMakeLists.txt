project(GodotFmod)
cmake_minimum_required(VERSION 3.6)

set(GODOT_GDEXTENSION_DIR godot-cpp/gdextension/ CACHE STRING "Path to GDExtension interface header directory")
set(CPP_BINDINGS_PATH godot-cpp/ CACHE STRING "Path to C++ bindings")

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(TARGET_PATH x11)
    set(OS "linux")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(TARGET_PATH win64)
    set(OS "windows")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(TARGET_PATH macos)
    set(OS "osx")
else()
    message(FATAL_ERROR "Not implemented support for ${CMAKE_SYSTEM_NAME}")
endif()

add_compile_definitions(TOOLS_ENABLED)
add_compile_definitions(DEBUG_ENABLED)

# Change the output directory to the bin directory
set(BUILD_PATH ${CMAKE_SOURCE_DIR}/bin/${TARGET_PATH})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${BUILD_PATH}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${BUILD_PATH}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${BUILD_PATH}")
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${BUILD_PATH}")
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${BUILD_PATH}")
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${BUILD_PATH}")
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${BUILD_PATH}")
SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${BUILD_PATH}")
SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${BUILD_PATH}")

# Set the c++ standard to c++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(GODOT_COMPILE_FLAGS )
set(GODOT_LINKER_FLAGS )

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    # using Visual Studio C++
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /EHsc /WX") # /GF /MP
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /DTYPED_METHOD_BIND")

    if(CMAKE_BUILD_TYPE MATCHES Debug)
        set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /MDd") # /Od /RTC1 /Zi
    else()
        set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /MD /O2") # /Oy /GL /Gy
        STRING(REGEX REPLACE "/RTC(su|[1su])" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
        string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})
    endif(CMAKE_BUILD_TYPE MATCHES Debug)

    # Disable conversion warning, truncation, unreferenced var, signed mismatch
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /wd4244 /wd4305 /wd4101 /wd4018 /wd4267")

    add_definitions(-DNOMINMAX)

    # Unkomment for warning level 4
    #if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
    #	string(REGEX REPLACE "/W[0-4]" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    #endif()

else()

    #elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    # using Clang
    #elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    # using GCC and maybe MinGW?

    set(GODOT_LINKER_FLAGS "-static-libgcc -static-libstdc++ -Wl,-R,'$$ORIGIN'")

    # Hmm.. maybe to strikt?
    set(GODOT_COMPILE_FLAGS "-fPIC -g -Wwrite-strings")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wchar-subscripts -Wcomment -Wdisabled-optimization")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wformat -Wformat=2 -Wformat-security -Wformat-y2k")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wimport -Winit-self -Winline -Winvalid-pch -Werror")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wmissing-braces -Wmissing-format-attribute")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wmissing-include-dirs -Wmissing-noreturn -Wpacked -Wpointer-arith")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wredundant-decls -Wreturn-type -Wsequence-point")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wswitch -Wswitch-enum -Wtrigraphs")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wuninitialized -Wunknown-pragmas -Wunreachable-code -Wunused-label")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wunused-value -Wvariadic-macros -Wvolatile-register-var -Wno-error=attributes")

    # -Wshadow -Wextra -Wall -Weffc++ -Wfloat-equal -Wstack-protector -Wunused-parameter -Wsign-compare -Wunused-variable -Wcast-align
    # -Wunused-function -Wstrict-aliasing -Wstrict-aliasing=2 -Wmissing-field-initializers

    if(NOT CMAKE_SYSTEM_NAME STREQUAL "Android")
        set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wno-ignored-attributes")
    endif()

    if(CMAKE_BUILD_TYPE MATCHES Debug)
        set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -fno-omit-frame-pointer -O0")
    else()
        set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -O3")
    endif(CMAKE_BUILD_TYPE MATCHES Debug)
endif()

# Get Sources
file(GLOB_RECURSE SOURCES src/*.c** src/**/*.c**)
file(GLOB_RECURSE HEADERS src/*.h** src/**/*.h**)

# Define our godot-cpp library
add_library(${PROJECT_NAME} SHARED ${SOURCES} ${HEADERS})

target_include_directories(${PROJECT_NAME} SYSTEM
        PRIVATE
        src/
        ${CPP_BINDINGS_PATH}/include
        ${CPP_BINDINGS_PATH}/include/godot_cpp
        ${CPP_BINDINGS_PATH}/gen/include
        ${CPP_BINDINGS_PATH}/gen/include/godot_cpp
        ${GODOT_GDEXTENSION_DIR}
        )

link_directories("../libs/fmod/${OS}/core/lib/")
link_directories("../libs/fmod/${OS}/studio/lib/")
include_directories(../libs/fmod/${OS}/core/inc ../libs/fmod/${OS}/studio/inc)

# Create the correct name (godot.os.build_type.system_bits)
# Synchronized with godot-cpp's CMakeLists.txt

set(BITS 32)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(BITS 64)
endif(CMAKE_SIZEOF_VOID_P EQUAL 8)

if(CMAKE_BUILD_TYPE MATCHES Debug)
    set(GODOT_CPP_BUILD_TYPE Debug)
else()
    set(GODOT_CPP_BUILD_TYPE Release)
endif()

string(TOLOWER ${CMAKE_SYSTEM_NAME} SYSTEM_NAME)
string(TOLOWER ${GODOT_CPP_BUILD_TYPE} BUILD_TYPE)

if(ANDROID)
    # Added the android abi after system name
    set(SYSTEM_NAME ${SYSTEM_NAME}.${ANDROID_ABI})
endif()

if(CMAKE_VERSION VERSION_GREATER "3.13")
    target_link_directories(${PROJECT_NAME}
            PRIVATE
            ${CPP_BINDINGS_PATH}/bin/
            )

    target_link_libraries(${PROJECT_NAME}
            godot-cpp.${SYSTEM_NAME}.${BUILD_TYPE}$<$<NOT:$<PLATFORM_ID:Android>>:.${BITS}>
            )
else()
    target_link_libraries(${PROJECT_NAME}
            ${CPP_BINDINGS_PATH}/bin/libgodot-cpp.${SYSTEM_NAME}.${BUILD_TYPE}$<$<NOT:$<PLATFORM_ID:Android>>:.${BITS}>.a
            )
endif()

if (${OS} EQUAL "osx")
    target_link_libraries(${PROJECT_NAME} libgodot-cpp.osx.64.a libfmod.dylib libfmodstudio.dylib)
endif ()
if (${OS} EQUAL "windows")
    target_link_libraries(${PROJECT_NAME} libgodot-cpp.windows.64.lib fmod64.dll fmodstudio64.dll)
endif ()
if (${OS} EQUAL "linux")
    target_link_libraries(${PROJECT_NAME} libgodot-cpp.linux.64.a libfmod.so libfmodstudio.so)
endif()


# Add the compile flags
set_property(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY COMPILE_FLAGS ${GODOT_COMPILE_FLAGS})
set_property(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY LINK_FLAGS ${GODOT_LINKER_FLAGS})

set_property(TARGET ${PROJECT_NAME} PROPERTY OUTPUT_NAME "GodotFmod")