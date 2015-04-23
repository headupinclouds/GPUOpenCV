set(CMAKE_MODULE_PATH @CMAKE_MODULE_PATH@) # fetch top level CMAKE_MODULE_PATH

message(">:>:>:>:>:>:>:>:>:>:>:>:>:>:>:>:>: ${CMAKE_MODULE_PATH} <:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:<:")

# possibly import these via CMakeLists.txt: i.e., @is_ios@, etc
string(COMPARE EQUAL "${CMAKE_OSX_SYSROOT}" "iphoneos" is_ios)
string(COMPARE EQUAL "${CMAKE_SYSTEM_NAME}" "Linux" is_linux)

### OpenCV
# Note: This will be more complicated for the final release
if(is_ios)
   set(OPENCV_CMAKE_ARGS BUILD_SHARED_LIBS=OFF WITH_FFMPEG=OFF) #TBD
elseif(APPLE)
   include(SetOpenCVCMakeArgs-osx) # shorten long list
   set_opencv_cmake_args_osx()
elseif(is_linux)
   set(OPENCV_CMAKE_ARGS BUILD_SHARED_LIBS=OFF WITH_FFMPEG=OFF) #TBD
elseif(MSCV)
   set(OPENCV_CMAKE_ARGS BUILD_SHARED_LIBS=OFF WITH_FFMPEG=OFF) #TBD
elseif(ANDROID)
   set(OPENCV_CMAKE_ARGS BUILD_SHARED_LIBS=OFF WITH_FFMPEG=OFF) #TBD
endif()

hunter_config(OpenCV VERSION 3.0.0-beta-p2 CMAKE_ARGS "${OPENCV_CMAKE_ARGS}")

### GPUImage
hunter_config(GPUImage VERSION 0.1.6-p4)

### cvmatio
hunter_config(cvmatio VERSION 1.0.18)

### ZLIB
hunter_config(ZLIB VERSION 1.2.8-p2)

### TIFF 
hunter_config(TIFF VERSION 4.0.2-hunter-2)

### Boost
hunter_config(Boost VERSION 1.57.0)

### DLIB
hunter_config(dlib VERSION 18.14)

### EIGEN
hunter_config(Eigen VERSION 3.2.4)

### CSV-PARSER-CPLUSPLUS
hunter_config(CsvParserCPlusPlus VERSION 1.0.1)
