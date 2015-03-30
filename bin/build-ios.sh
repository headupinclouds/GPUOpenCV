#!/bin/bash

GPUOPENCV_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
GPUOPENCV_DIR=${GPUOPENCV_DIR}/../
echo "GPUOPENCV_DIR ${GPUOPENCV_DIR}"

CMAKE_OSX_PLATFORM=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform
CMAKE_OSX_SYSROOT=${CMAKE_OSX_PLATFORM}/Developer/SDKs/iPhoneOS8.2.sdk/System/Library/Frameworks

#
# HACK!!!! Seems to be needed to pick up custom (non system) frameworks
#
echo "About to make links to {opencv2,GPUImage}.framework from ${CMAKE_OSX_SYSROOT}"
[ ! -s ${CMAKE_OSX_SYSROOT}/opencv2.framework ] && sudo ln -s ${GPUOPENCV_DIR}/prebuilt/ios/GPUImage.framework ${CMAKE_OSX_SYSROOT}
[ ! -s ${CMAKE_OSX_SYSROOT}/GPUImage.framework ] &&  sudo ln -s ${GPUOPENCV_DIR}/prebuilt/ios/opencv2.framework ${CMAKE_OSX_SYSROOT}

#rm ${CMAKE_OSX_SYSROOT}/opencv2.framework
#rm ${CMAKE_OSX_SYSROOT}/GPUImage.framework

NAME=ios-xcode-shared
GPUOPENCV_BUILD=${GPUOPENCV_DIR}/build
[ ! -d ${GPUOPENCV_BUILD}/${NAME} ] && mkdir -p ${GPUOPENCV_BUILD}/${NAME}

IOS_CMAKE=${GPUOPENCV_DIR}/cmake/iOS.cmake 

#(cd ${GPUOPENCV_BUILD}/${NAME}; echo ${PWD})

(cd ${GPUOPENCV_BUILD}/${NAME}; \
    cmake -H. -GXcode ${GPUOPENCV_DIR} \
    -DCMAKE_TOOLCHAIN_FILE=${IOS_CMAKE} \
    -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration" \
    && echo "Shared build tree is located here : $GPUOPENCV_BUILD" \
    && open ${GPUOPENCV_BUILD}/${NAME}/GPUOPENCV.xcodeproj)

