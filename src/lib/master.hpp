#ifndef GPUOPENCV_MASTER_H
#define GPUOPENCV_MASTER_H


#define _BEGIN_MASTER namespace master {
#define _END_MASTER }

_BEGIN_MASTER

class GPUOpenCVMaster
{
public:
    GPUOpenCVMaster();
    int operator()(int x, int y);
};

_END_MASTER

#endif // GPUOPENCV_MASTER_H
