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
include(MacroParallelMake) # support make -jN via command line -DMULTITHREADED_BUILD=8
PARALLEL_MAKE()

# ((((( OpenCV )))))
if(is_ios)
  message("Use the OpenCV-ios hunter packages to grab the iOS framework (TODO)") 
elseif(APPLE)
  message ("Configure OpenCV for OS X") 
  include(SetOpenCVCMakeArgs-osx) # shorten long list
  set_opencv_cmake_args_osx()
elseif(is_linux)
  message("Configure minimal OpenCV for Linux (TODO)")
  set(OPENCV_CMAKE_ARGS WITH_FFMPEG=OFF)
elseif(MSCV)
  message("Configure minimal OpenCV for MSVC (TODO)")
  set(OPENCV_CMAKE_ARGS WITH_FFMPEG=OFF WITH_OPENEXR=OFF)
elseif(ANDROID)
  message("Configure minimal OpenCV for Android (TODO)")
  set(OPENCV_CMAKE_ARGS WITH_FFMPEG=OFF)
endif()
message("OPENCV_CMAKE_ARGS ${OPENCV_CMAKE_ARGS}")
hunter_config(OpenCV VERSION 3.0.0-beta CMAKE_ARGS "${OPENCV_CMAKE_ARGS}")
hunter_add_package(OpenCV)
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

message("OPENCV INCLUDE FROM CMAKE: ${OpenCV_INCLUDE_DIRS} ....................${OpenCV_DIR}")

# Find the BOOST libraries (TODO: possibly use hunter, very big/slow)
find_package(Boost 1.55 REQUIRED system serialization filesystem)

# cvmatio (Boost, OpenCV, ZLib)

# GSTreamer detection for ZLIB causes assert to faile, so we need to specify this manually
set(CVMATIO_CMAKE_ARGS "OpenCV_DIR=${OpenCV_DIR};ZLIB_ROOT=/usr/include;ZLIB_INCLUDE_ROOT=/usr/include")
message("CVMATIO_CMAKE_ARGS ${CVMATIO_CMAKE_ARGS}")

hunter_config(cvmatio VERSION 1.0.2 CMAKE_ARGS "${CVMATIO_CMAKE_ARGS}")
hunter_add_package(cvmatio) # header only
find_library(
  cvmatio_release
  cvmatio
  ${cvmatio_ROOT}
)
find_library(
  cvmatio_debug
  cvmatio${CMAKE_DEBUG_POSTFIX}
  ${cvmatio_ROOT}
)
message("Release: ${cvmatio_release}")
message("Debug: ${cvmatio_debug}")
#find_package(cvmatio REQUIRED)

if(APPLE)
  include(MacroAddFramework)
endif()

include_directories(src/lib)
add_subdirectory(src)
