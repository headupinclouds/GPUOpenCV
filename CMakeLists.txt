cmake_minimum_required(VERSION 3.0)

project(GPUOpenCV)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

#
# Desired behavior: 
#
#

include(ExternalProject)

set(PREFIX "${CMAKE_CURRENT_BINARY_DIR}")
set(INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}")
set(CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR})

### Hunter snapshot that will be used ###
include("cmake/HunterGate.cmake")
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.5.10.tar.gz"
    SHA1 "d534c6f3ab9c53c325ca4d3607f65bbf981913db"
)

#hunter_add_package(OpenCV)

find_library(OpenCV_release OpenCV ${OPENCV_ROOT})

### Download dependencies ###
#hunter_add_package(GTest)

### Find dependencies ###
#find_package(GTest CONFIG REQUIRED NO_CMAKE_BUILDS_PATH) # GTest::main

# https://github.com/Itseez/opencv/archive/3.0.0-beta.tar.gz

#ExternalProject_Add(opencv
#  PREFIX ${PREFIX}
#  GIT_REPOSITORY https://github.com/Itseez/opencv.git
#  GIT_TAG 3.0.0-beta
#  INSTALL_DIR ${INSTALL_DIR}
#  CMAKE_ARGS ${CMAKE_ARGS}
#)

if(CMAKE_GENERATOR STREQUAL Xcode)
   set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")
   set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
   set(CMAKE_XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES)
else()

   # list(APPEND CMAKE_CXX_FLAGS "-std=c++11")
   # list(APPEND CMAKE_CXX_FLAGS "-stdlib=libc++")
   set (CMAKE_CXX_FLAGS " -std=c++11 -stdlib=libc++")

endif()

if(APPLE)
  include(MacroAddFramework)
  if(IOS)
     
     # Find {GPUImage,opencv2}.framework at top level?
     # This currently runs in GPUOpenCV/src/app/SimpleVideoFilter/SimpleVideoFilter/CMakeLists.txt

  else() 

      # This would have to be OS X (better way to confirm "Darwin" ?)

      # To get the build running end-to-end we rely on prebuilt opencv libraries
      set(OpenCV_DIR "${CMAKE_SOURCE_DIR}/prebuilt/osx/opencv-3.0.0-osx-static/share/OpenCV")
      set(CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/prebuilt/osx/opencv-3.0.0-osx-static/share/OpenCV")

  endif()

endif()

# Find OpenCV package in top level file for future use:
find_package( OpenCV REQUIRED )
include_directories(${OpenCV_INCLUDE_DIRS})

add_subdirectory(src)


