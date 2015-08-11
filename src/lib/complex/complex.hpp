#ifndef GPUOPENCV_COMPLEX_H
#define GPUOPENCV_COMPLEX_H

#include <numeric>
#include <cmath>

#include <gpuopencv_export.h> // GPUOPENCV_EXPORT

#define _BEGIN_COMPLEX namespace complex {
#define _END_COMPLEX }

_BEGIN_COMPLEX

class GPUOPENCV_EXPORT GPUOpenCVComplex
{
public:
    GPUOpenCVComplex();
    int operator()(int x, int y);
};

_END_COMPLEX

#endif // GPUOPENCV_COMPLEX_H
