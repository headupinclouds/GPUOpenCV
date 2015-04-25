cmake_minimum_required(VERSION 3.0)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/Modules")

configure_file(cmake/Hunter/config.cmake "${CMAKE_BINARY_DIR}/hunter-config.cmake" @ONLY)

include("cmake/HunterGate.cmake")
### Hunter snapshot that will be used ###
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.8.13.tar.gz"
    SHA1 "7103f0ab481523ca93a06c1c55abcd56741d3a97"
    FILEPATH "${CMAKE_BINARY_DIR}/hunter-config.cmake"
)

project(GPUOpenCV)

# See: cmake/Hunter/config.cmake
hunter_add_package(Sugar)
include("${SUGAR_ROOT}/cmake/Sugar")

string(COMPARE EQUAL "${CMAKE_OSX_SYSROOT}" "iphoneos" is_ios)
string(COMPARE EQUAL "${CMAKE_SYSTEM_NAME}" "Linux" is_linux)
string(COMPARE EQUAL "${CMAKE_BUILD_TYPE}" "DEBUG" is_debug)
string(COMPARE EQUAL "${CMAKE_GENERATOR}" "Xcode" is_xcode)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)

## the following are directories where stuff will be installed to
## (see taglib/CMakeLists.txt)
set(LIB_SUFFIX_TXT "Define suffix of directory name (32/64)")
set(EXEC_INSTALL_PREFIX_TXT "Base directory for executables and libraries")
set(BIN_INSTALL_DIR_TXT "The subdirectory to the binaries prefix (default prefix/bin)")
set(LIB_INSTALL_TXT "The subdirectory relative to the install prefix where libraries will be installed (default is /lib${LIB_SUFFIX}")
set(INCLUDE_INSTALL_DIR_TXT "The subdirectory to the header prefix")

set(LIB_SUFFIX "" CACHE STRING "${LIB_SUFFIX_TXT}")
set(EXEC_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH "${EXEC_INSTALL_PREFIX_TXT}" FORCE)
set(BIN_INSTALL_DIR "${EXEC_INSTALL_PREFIX}/bin" CACHE PATH "${BIN_INSTALL_DIR_TXT}" FORCE)
set(LIB_INSTALL_DIR "${EXEC_INSTALL_PREFIX}/lib${LIB_SUFFIX}" CACHE PATH "${LIB_INSTALL_TXT}" FORCE)
set(INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE PATH "${INCLUDE_INSTALL_DIR_TXT}" FORCE)

# Desired behavior:
set(PREFIX "${CMAKE_CURRENT_BINARY_DIR}")
set(INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}")
set(CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}")

# Set the cmake/Modules path and pull in some convenience macros
include(ExternalProject)
include(hunter_cmake_args)
include(ForEachPrepend)
include(MacroParallelMake) # support make -jN via command line -DMULTITHREADED_BUILD=8

PARALLEL_MAKE()

#   ZLIB_INCLUDE_DIRS   - where to find zlib.h, etc.
#   ZLIB_LIBRARIES      - List of libraries when using zlib.
#   ZLIB_FOUND          - True if zlib found.
hunter_add_package(ZLIB)
find_package(ZLIB CONFIG)

#   TIFF_INCLUDE_DIR, where to find tiff.h, etc.
#   TIFF_LIBRARIES, libraries to link against to use TIFF.
#   TIFF_FOUND, If false, do not try to use TIFF.
hunter_add_package(TIFF)
find_package(TIFF CONFIG)

hunter_add_package(OpenCV)
find_package(OpenCV CONFIG REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

# (((((( Boost ))))))
#
# 1) Do we need to include Boost here if the cvmatio package will include this
# as a dependnecy?
# 2) Will this be compiled 1x?

hunter_add_package(Boost COMPONENTS filesystem system serialization)
find_package(Boost COMPONENTS filesystem system serialization)

# https://github.com/ruslo/hunter/wiki/pkg.boost

# MSVC build
if(MSVC)
  add_definitions(-DBOOST_ALL_NO_LIB=1)
endif()
# Detect iOS build
if(is_ios)
  # Strange iOS alignment(?) bug (TODO)
  #target_compile_definitions(sober PUBLIC BOOST_SP_NO_SYNC)
endif()

# ((((((( CVMATIO )))))))

hunter_add_package(cvmatio)
#find_package(cvmatio) <= TODO: add FineCVMatIO.cmake
find_path(CVMATIO_INCLUDE_DIR NAMES MatlabIOContainer.hpp "${CVMATIO_ROOT}")
find_library(cvmatio_release NAMES cvmatio "${CVMATIO_ROOT}")
find_library(cvmatio_debug NAMES cvmatio${CMAKE_DEBUG_POSTFIX} "${CVMATIO_ROOT}")
if(is_debug)
  set(CVMATIO_LIB "${cvmatio_debug}")
else()
  set(CVMATIO_LIB "${cvmatio_release}")
endif(is_debug)

# (((((( GPUIMAGE ))))))

if(APPLE)

  # GPUImage apps are enabled on both iOS and OS X
  hunter_add_package(GPUImage)
  find_package(GPUImage CONFIG) # ${GPUIMAGE_INCLUDE_DIR} ${GPUIMAGE_LIBRARY} ${GPUIMAGE_FOUND}
  include_directories("${GPUIMAGE_INCLUDE_DIR}")

  # https://github.com/ruslo/hunter/wiki/pkg.gpuimage
  # RUSLO: How can we print the GPUImage::gpuimage alias?
endif()

#
# Testing versioned libs and Framework builds (based on https://github.com/taglib/taglib)
#

# Library configuration stuff
set(GPUOPENCV_LIB_MAJOR_VERSION "1")
set(GPUOPENCV_LIB_MINOR_VERSION "0")
set(GPUOPENCV_LIB_PATCH_VERSION "0")
set(GPUOPENCV_LIB_VERSION_STRING "${GPUOPENCV_LIB_MAJOR_VERSION}.${GPUOPENCV_LIB_MINOR_VERSION}.${GPUOPENCV_LIB_PATCH_VERSION}")

# 1. If the library source code has changed at all since the last update, then increment revision.
# 2. If any interfaces have been added, removed, or changed since the last update, increment current, and set revision to 0.
# 3. If any interfaces have been added since the last public release, then increment age.
# 4. If any interfaces have been removed since the last public release, then set age to 0.
set(GPUOPENCV_SOVERSION_CURRENT  1)
set(GPUOPENCV_SOVERSION_REVISION 0)
set(GPUOPENCV_SOVERSION_AGE      0)

math(EXPR GPUOPENCV_SOVERSION_MAJOR "${GPUOPENCV_SOVERSION_CURRENT} - ${GPUOPENCV_SOVERSION_AGE}")
math(EXPR GPUOPENCV_SOVERSION_MINOR "${GPUOPENCV_SOVERSION_AGE}")
math(EXPR GPUOPENCV_SOVERSION_PATCH "${GPUOPENCV_SOVERSION_REVISION}")

if(APPLE)
  option(BUILD_FRAMEWORK "Build an OS X framework" OFF)
  set(FRAMEWORK_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/Library/Frameworks" CACHE STRING "Directory to install frameworks to.")
endif()

include_directories(src/lib)
add_subdirectory(src)

message("${PROJECT_NAME}:")
message("-- system --")
message("  APPLE: ${APPLE}")
message("  iOS: ${is_ios}")
message("-- configuration --")
message("  Build shared libraries: ${BUILD_SHARED_LIBS}")
message("-- packages --")
message("  Sugar: ${SUGAR_ROOT}/cmake/Sugar")
message("  ZLIB: ${ZLIB_DIR}")
message("  OpenCV: ${OpenCV_DIR}")
message("  CVMATIO: ${CVMATIO_DIR}")
message("  GPUImage: ${GPUImage_DIR}")
