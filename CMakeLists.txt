cmake_minimum_required(VERSION 3.0)
project(GPUOpenCV)

include(ExternalProject)

set(PREFIX "${CMAKE_CURRENT_BINARY_DIR}")
set(INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}")
set(CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR})

### Hunter snapshot that will be used ###
#include("cmake/HunterGate.cmake")
#HunterGate(
#    URL "https://github.com/ruslo/hunter/archive/v0.5.10.tar.gz"
#    SHA1 "d534c6f3ab9c53c325ca4d3607f65bbf981913db"
#)

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
   list(APPEND CMAKE_CXX_FLAGS "-std=c++11")
   list(APPEND CMAKE_CXX_FLAGS "-stdlib=libc++")
endif()

if(APPLE)
  macro(ADD_FRAMEWORK fwname appname)
    find_library(FRAMEWORK_${fwname}
      NAMES ${fwname}
      PATHS ${CMAKE_OSX_SYSROOT}/System/Library 
      PATH_SUFFIXES Frameworks
      NO_DEFAULT_PATH)
    if( ${FRAMEWORK_${fwname}} STREQUAL FRAMEWORK_${fwname}-NOTFOUND)
      MESSAGE(ERROR ": Framework ${fwname} not found")
    else()
      TARGET_LINK_LIBRARIES(${appname} "${FRAMEWORK_${fwname}}/${fwname}")
      MESSAGE(STATUS "Framework ${fwname} found at ${FRAMEWORK_${fwname}}")
    endif()
  endmacro(ADD_FRAMEWORK)



endif()


add_subdirectory(src)


