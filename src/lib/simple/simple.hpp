#ifndef GPUOPENCV_SIMPLE_H
#define GPUOPENCV_SIMPLE_H

#include <gpuopencv_export.h> // GPUOPENCV_EXPORT

#define _BEGIN_SIMPLE namespace simple {
#define _END_SIMPLE }

_BEGIN_SIMPLE

class GPUOPENCV_EXPORT GPUOpenCVSimple
{
public:
    GPUOpenCVSimple();
    int operator()(int x, int y);
};

_END_SIMPLE

#endif // GPUOPENCV_SIMPLE_H
