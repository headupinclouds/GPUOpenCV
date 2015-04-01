#!/bin/bash

GPUOPENCV_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
GPUOPENCV_DIR=${GPUOPENCV_DIR}/../
echo "GPUOPENCV_DIR ${GPUOPENCV_DIR}"

NAME=osx-xcode-static
GPUOPENCV_BUILD=${GPUOPENCV_DIR}/build
[ ! -d ${GPUOPENCV_BUILD}/${NAME} ] && mkdir -p ${GPUOPENCV_BUILD}/${NAME}

(cd ${GPUOPENCV_BUILD}/${NAME}; \
    cmake -H. -G "Unix Makefiles" ${GPUOPENCV_DIR} \
    -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration" \
    && echo "Static build tree is located here : $GPUOPENCV_BUILD" )


