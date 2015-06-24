cmake_minimum_required(VERSION 3.0)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/Modules")

set(custom_config "${CMAKE_CURRENT_BINARY_DIR}/hunter-config.cmake")
configure_file(cmake/Hunter/config.cmake "${custom_config}" @ONLY)

include("cmake/HunterGate.cmake")
### Hunter snapshot that will be used ###
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.8.13.tar.gz"
    SHA1 "7103f0ab481523ca93a06c1c55abcd56741d3a97"
    FILEPATH "${custom_config}"
)

project(GPUOpenCV VERSION 0.1.0)

# See: cmake/Hunter/config.cmake
hunter_add_package(Sugar)
include("${SUGAR_ROOT}/cmake/Sugar")

string(COMPARE EQUAL "${CMAKE_OSX_SYSROOT}" "iphoneos" is_ios)
string(COMPARE EQUAL "${CMAKE_BUILD_TYPE}" "DEBUG" is_debug)
string(COMPARE EQUAL "${CMAKE_GENERATOR}" "Xcode" is_xcode)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)

if(APPLE)
  set(CMAKE_MACOSX_RPATH ON)
  set(CMAKE_SKIP_BUILD_RPATH FALSE)
  set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
  set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
  list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
  if("${isSystemDir}" STREQUAL "-1")
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
  endif()
endif()

## only static libs for ios
if(is_ios)
  set(BUILD_SHARED_LIBS OFF)
endif()

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
include(MergeStaticLibraries)
include(MacroParallelMake) # support make -jN via command line -DMULTITHREADED_BUILD=8

PARALLEL_MAKE()

#   ZLIB_INCLUDE_DIRS   - where to find zlib.h, etc.
#   ZLIB_LIBRARIES      - List of libraries when using zlib.
#   ZLIB_FOUND          - True if zlib found.
hunter_add_package(ZLIB)
find_package(ZLIB CONFIG REQUIRED)

#   TIFF_INCLUDE_DIR, where to find tiff.h, etc.
#   TIFF_LIBRARIES, libraries to link against to use TIFF.
#   TIFF_FOUND, If false, do not try to use TIFF.
hunter_add_package(TIFF)
find_package(TIFF CONFIG REQUIRED)

hunter_add_package(OpenCV)
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

# (((((( Boost ))))))
hunter_add_package(Boost COMPONENTS system filesystem serialization)
find_package(Boost CONFIG REQUIRED system filesystem serialization)

################
###TEST ERROR###
################
option(TEST_SCOPE_ISSUE "Test scope issue with static lib::lib dependencies" OFF)
if(TEST_SCOPE_ISSUE)
  add_definitions(-DTEST_SCOPE_ISSUE=1)
  set(TEST_SCOPE_ISSUE_LIBS
    Boost::filesystem # Use this artificially in libsimple to test static libs
    Boost::system 
    )
endif()

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
#hunter_add_package(cvmatio) 
#find_package(cvmatio REQUIRED CONFIG)

# (((((( GPUIMAGE ))))))
if(APPLE)
  # GPUImage apps are enabled on both iOS and OS X
  hunter_add_package(GPUImage)
  find_package(GPUImage CONFIG) # ${GPUIMAGE_INCLUDE_DIR} ${GPUIMAGE_LIBRARY} ${GPUIMAGE_FOUND}
  # https://github.com/ruslo/hunter/wiki/pkg.gpuimage
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
