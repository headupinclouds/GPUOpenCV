# This file generated automatically by:
#   generate_sugar_files.py
# see wiki for more info:
#   https://github.com/ruslo/sugar/wiki/Collecting-sources

if(DEFINED COMPLEX_SUGAR_CMAKE_)
  return()
else()
  set(COMPLEX_SUGAR_CMAKE_ 1)
endif()

include(sugar_files)

sugar_files(
    GPUOPENCV_COMPLEX_SRCS
    complex.cpp
)

sugar_files(
    GPUOPENCV_COMPLEX_PUBLIC_HDRS
    complex.hpp
)
