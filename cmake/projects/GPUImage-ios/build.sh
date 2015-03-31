#!/bin/bash

NAME=GPUImage
VERSION=0.1.6

TESTDIR=/tmp/

pushd ${TESTDIR}

wget https://github.com/BradLarson/${NAME}/archive/${VERSION}.tar.gz
openssl sha1 ${VERSION}.tar.gz # 977ee3f74e0dcf366a2e2f3fc1b89cba3fce3428

tar xf ${VERSION}.tar.gz
cd ${NAME}-${VERSION}

# Note: this is just a basic xcodebuild -project followed by framework construction
# Perhaps there is a simple template that would work for this across multiple Xcode projects

set -e
IOSSDK_VER="8.2"
# xcodebuild -showsdks
function build_framework
{
    cd framework
    xcodebuild -project ${NAME}.xcodeproj -target ${NAME} -configuration Release -sdk iphoneos${IOSSDK_VER} build
    xcodebuild -project ${NAME}.xcodeproj -target ${NAME} -configuration Release -sdk iphonesimulator${IOSSDK_VER} build
}

function make_framework
{
    cd build
    # for the fat lib file
    mkdir -p Release-iphone/lib
    xcrun -sdk iphoneos lipo -create Release-iphoneos/lib${NAME}.a Release-iphonesimulator/lib${NAME}.a -output Release-iphone/lib/lib${NAME}.a
    xcrun -sdk iphoneos lipo -info Release-iphone/lib/lib${NAME}.a
    # for header files
    mkdir -p Release-iphone/include
    bash -c "cp ../framework/Source/*.h Release-iphone/include"
    bash -c "cp ../framework/Source/iOS/*.h Release-iphone/include"

    # Build static framework
    mkdir -p ${NAME}.framework/Versions/A
    cp Release-iphone/lib/lib${NAME}.a ${NAME}.framework/Versions/A/${NAME}
    mkdir -p ${NAME}.framework/Versions/A/Headers
    bash -c "cp Release-iphone/include/*.h ${NAME}.framework/Versions/A/Headers"
    ln -sfh A ${NAME}.framework/Versions/Current
    ln -sfh Versions/Current/${NAME} ${NAME}.framework/${NAME}
    ln -sfh Versions/Current/Headers ${NAME}.framework/Headers
}

( build_framework )
( make_framework )
echo "Build here =>  ${NAME}-${VERSION}/build/${NAME}.framework"

popd
