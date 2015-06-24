# This file generated automatically by:
#   generate_sugar_files.py
# see wiki for more info:
#   https://github.com/ruslo/sugar/wiki/Collecting-sources

if(DEFINED SUGAR_CMAKE_)
  return()
else()
  set(SUGAR_CMAKE_ 1)
endif()

include(sugar_files)
include(sugar_include)

sugar_include(complex)
sugar_include(simple)

sugar_files(
  GPUOPENCV_SRCS
  master.cpp
)

sugar_files(
  GPUOPENCV_PUBLIC_HDRS
  master.hpp
)


