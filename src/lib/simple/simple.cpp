#include "simple/simple.hpp"

_BEGIN_SIMPLE

GPUOpenCVSimple::GPUOpenCVSimple()
{
    
}

int GPUOpenCVSimple::operator()(int x, int y) 
{ 
    return x + y; 
}

_END_SIMPLE
