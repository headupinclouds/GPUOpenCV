#include <iostream>

#include "simple/simple.hpp"
#include "complex/complex.hpp"

int main(int argc, char **argv)
{
    int a = simple::GPUOpenCVSimple()(1, 2);
    int b = complex::GPUOpenCVComplex()(1, 2);
    std::cout << "test_gpuopencv: " << a << std::endl;
}
