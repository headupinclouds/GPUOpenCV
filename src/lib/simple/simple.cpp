#include "simple/simple.hpp"
#include "simple/simple_private.hpp"

_BEGIN_SIMPLE

GPUOpenCVSimple::GPUOpenCVSimple()
{
    
}

int GPUOpenCVSimple::operator()(int x, int y) 
{ 
    return simple_private_add(x, y);
}

_END_SIMPLE
