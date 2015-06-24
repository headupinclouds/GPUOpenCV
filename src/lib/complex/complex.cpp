#include "complex/complex.hpp"

// Use OpenCV functionality to exercise 3rd party static dependency
#include <opencv2/core/core.hpp>

_BEGIN_COMPLEX

GPUOpenCVComplex::GPUOpenCVComplex()
{
    
}

int GPUOpenCVComplex::operator()(int x, int y) 
{ 
#if 0
    return std::sqrt(x*x + y*y);
#else
    return static_cast<int>(cv::norm(cv::Point(x, y))); // use this just to test dependency
#endif
}

_END_COMPLEX
