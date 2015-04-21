# Find GPUImage
#
#  GPUIMAGE_INCLUDE_DIR - where to find GPUImage/logging.h, etc.
#  GPUIMAGE_LIBRARY     - List of libraries when using libglog.
#  GPUIMAGE_FOUND       - True if libglog found.
#
# Lineage: 4/21/2015
#   Modified from https://github.com/facebook/hhvm/blob/master/CMake/FindGlog.cmake

IF (GPUIMAGE_INCLUDE_DIR)
  # Already in cache, be silent
  SET(GPUIMAGE_FIND_QUIETLY TRUE)
ENDIF ()

FIND_PATH(GPUIMAGE_INCLUDE_DIR GPUImage/GPUImage.h)

FIND_LIBRARY(GPUIMAGE_LIBRARY gpuimage)

# handle the QUIETLY and REQUIRED arguments and set Libmemcached_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GPUIMAGE DEFAULT_MSG GPUIMAGE_LIBRARY GPUIMAGE_INCLUDE_DIR)

MARK_AS_ADVANCED(GPUIMAGE_LIBRARY GPUIMAGE_INCLUDE_DIR)
