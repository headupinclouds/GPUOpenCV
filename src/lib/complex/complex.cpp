#include "complex/complex.hpp"

_BEGIN_COMPLEX

GPUOpenCVComplex::GPUOpenCVComplex()
{
    
}

int GPUOpenCVComplex::operator()(int x, int y) 
{ 
    return std::sqrt(x*x + y*y);
}

_END_COMPLEX
