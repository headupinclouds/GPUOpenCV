# This file generated automatically by:
#   generate_sugar_files.py
# see wiki for more info:
#   https://github.com/ruslo/sugar/wiki/Collecting-sources

if(DEFINED SIMPLE_SUGAR_CMAKE_)
  return()
else()
  set(SIMPLE_SUGAR_CMAKE_ 1)
endif()

include(sugar_files)

sugar_files(
    GPUOPENCV_SIMPLE_SRCS
    simple.cpp
    simple_private.cpp
)

sugar_files(
    GPUOPENCV_SIMPLE_PUBLIC_HDRS
    simple.hpp
)
