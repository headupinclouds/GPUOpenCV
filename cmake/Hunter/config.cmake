set(CMAKE_MODULE_PATH @CMAKE_MODULE_PATH@) # fetch top level CMAKE_MODULE_PATH

message(">:>:>:>:>:>:>:>:>:>:>:>:>:>:>:>:>: ${CMAKE_MODULE_PATH} <:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:")

string(COMPARE EQUAL "${CMAKE_OSX_SYSROOT}" "iphoneos" is_ios)
string(COMPARE EQUAL "${CMAKE_SYSTEM_NAME}" "Linux" is_linux)

# ((((( OpenCV )))))
# Note: This will be more complicated for the final release
if(is_ios)
   message ("Configure OpenCV for ios") 
elseif(APPLE)
   include(SetOpenCVCMakeArgs-osx) # shorten long list
   set_opencv_cmake_args_osx()
elseif(is_linux)
   set(OPENCV_CMAKE_ARGS WITH_FFMPEG=OFF) #TBD
elseif(MSCV)
   set(OPENCV_CMAKE_ARGS WITH_FFMPEG=OFF WITH_OPENEXR=OFF) #TBD
elseif(ANDROID)
   set(OPENCV_CMAKE_ARGS WITH_FFMPEG=OFF) #TBD
endif()

hunter_config(OpenCV VERSION 3.0.0-beta-p2 CMAKE_ARGS "${OPENCV_CMAKE_ARGS}")

# (((((( GPUImage ))))))
hunter_config(GPUImage VERSION 0.1.6-hunter-1)