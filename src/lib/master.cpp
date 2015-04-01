#include "master.hpp"

_BEGIN_MASTER

GPUOpenCVMaster::GPUOpenCVMaster()
{
    
}

int GPUOpenCVMaster::operator()(int x, int y) 
{ 
    return x + y; 
}

_END_MASTER
