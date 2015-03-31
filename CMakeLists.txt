cmake_minimum_required(VERSION 3.0)

project(GPUOpenCV)

string(COMPARE EQUAL "${CMAKE_OSX_SYSROOT}" "iphoneos" is_ios)
string(COMPARE EQUAL "${CMAKE_SYSTEM_NAME}" "Linux" is_linux)

# copied from hunter git repository
#include(hunter_cmake_args) 

# Desired behavior: 
set(PREFIX "${CMAKE_CURRENT_BINARY_DIR}")
set(INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}")
set(CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR})

### Hunter snapshot that will be used ###
include("cmake/HunterGate.cmake")
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.7.5.tar.gz"
    SHA1 "264a0bd8f658bb6f50767146bde080d7c9788baf"
)

# Link our local package definitions into the installed hunter directory (for loop ?)
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
  ${CMAKE_SOURCE_DIR}/cmake/projects/OpenCV
  ${HUNTER_SELF}/cmake/projects/OpenCV
)

# Set the cmake/Modules path and pull in some convenience macros
#set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/;${HUNTER_ROOT}/cmake/modules/")
message("MODULE_PATH: ${CMAKE_MODULE_PATH}")
include(ExternalProject) 
include(hunter_cmake_args)

# ((((( OpenCV )))))
if(is_ios)
  message("Use the OpenCV-ios hunter packages to grab the iOS framework (TODO)") 
elseif(APPLE)
  message ("Configure OpenCV for OS X") 
  set(OPENCV_CMAKE_ARGS WITH_FFMPEG:BOOL=OFF)
elseif(MSCV)
  message("Configure minimal OpenCV for MSVC (TODO)")
  set(OPENCV_CMAKE_ARGS WITH_FFMPEG:BOOL=OFF)
elseif(is_linux)
  message("Configure minimal OpenCV for Linux (TODO)")
  set(OPENCV_CMAKE_ARGS WITH_FFMPEG:BOOL=OFF)
elseif(ANDROID)
  message("Configure minimal OpenCV for Android (TODO)")
  set(OPENCV_CMAKE_ARGS WITH_FFMPEG:BOOL=OFF)
endif()

message("OPENCV_CMAKE_ARGS ${OPENCV_CMAKE_ARGS}")
hunter_config(OpenCV VERSION 3.0.0-beta CMAKE_ARGS "${OPENCV_CMAKE_ARGS}")
hunter_cmake_args(OpenCV CMAKE_ARGS "${OPENCV_CMAKE_ARGS}")
hunter_add_package(OpenCV)
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

if(APPLE)
  include(MacroAddFramework)
endif()

include_directories(src/lib)
add_subdirectory(src)


