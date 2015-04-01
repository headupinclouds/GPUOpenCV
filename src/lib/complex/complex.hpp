#ifndef GPUOPENCV_COMPLEX_H
#define GPUOPENCV_COMPLEX_H

#include <numeric>
#include <cmath>

#define _BEGIN_COMPLEX namespace complex {
#define _END_COMPLEX }

_BEGIN_COMPLEX

class GPUOpenCVComplex
{
public:
    GPUOpenCVComplex();
    int operator()(int x, int y);
};

_END_COMPLEX

#endif // GPUOPENCV_COMPLEX_H
