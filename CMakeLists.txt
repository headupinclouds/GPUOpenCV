cmake_minimum_required(VERSION 3.0)

project(GPUOpenCV)

string(COMPARE EQUAL "${CMAKE_OSX_SYSROOT}" "iphoneos" is_ios)

# Set the cmake/Modules path and pull in some convenience macros
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
include(ExternalProject) 

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

# HUNTER_SELF: ${CMAKE_SOURCE_DIR}/HunterPackages/_Base/264a0bd8f658bb6f50767146bde080d7c9788baf/Self

if(CMAKE_GENERATOR STREQUAL Xcode)
   set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")
   set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
   set(CMAKE_XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES)
else()
   set (CMAKE_CXX_FLAGS " -std=c++11 -stdlib=libc++") # Should this append instead ?
endif()

# Note sure if this is the right approach, each platform will have different (and potentially long)
# lists of CMAKE_ARGS

# Use 3.0.0-beta on all platforms, but customize CMAKR_ARGS using hunter_cmake_args ???


# Possibly define this 1x for all projects, but then use the newer hunter_cmake_args
# macro to customize the CMAKE_ARGS as needed for each platform. 

#hunter_config(OpenCV VERSION 3.0.0-beta)    

# For iOS it will need to run our new OpenCV-ios (non cmake) external download package. 
# That one uses an OpenCV python front end to CMake.  Possibly that role could be taken 
# over by hunter here.  I expect the python code is mostly needed for wrangling the framework.
# I've seen scattered posts about building iOS frameworks in CMake, so that would be
# worth checking to simplify things.

if(APPLE)
  if(is_ios)

    # Eventually use the OpenCV-ios hunter package, but for now
    # we just use prebuilt/ios/opencv2.framework
    message("Use the OpenCV-ios hunter packages TODO") 

  else() # NOT IOS (OS X)

    message ("Configure OpenCV for OS X") 

    # Enable these lines to test hunter build of opencv
    #include(HunterOpenCV-osx) # One of these for each platform???
    #hunter_config_opencv_osx()

    # comment out these lines to test hunter build of opencv (instead of prebuilt)
    set(OpenCV_DIR "${CMAKE_SOURCE_DIR}/prebuilt/osx/opencv-3.0.0-osx-static/share/OpenCV")
    set(CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/prebuilt/osx/opencv-3.0.0-osx-static/share/OpenCV")

  endif()
elseif(MSCV)
  message("Configure minimal OpenCV for MSVC (TODO)")
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  message("Configure minimal OpenCV for Linux (TODO)")
elseif(ANDROID)
  message("Configure minimal OpenCV for Android (TODO)")
endif()

# Uncomment this line to use the hunter build of OpenCV
# hunter_add_package(OpenCV)

if(APPLE)
  include(MacroAddFramework)
endif()

# Find OpenCV package in top level file for future use:
find_package( OpenCV REQUIRED )
include_directories(${OpenCV_INCLUDE_DIRS})

add_subdirectory(src)


