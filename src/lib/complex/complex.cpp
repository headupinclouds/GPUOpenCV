#include "complex/complex.hpp"

// Use OpenCV functionality to exercise 3rd party static dependency
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>

_BEGIN_COMPLEX

GPUOpenCVComplex::GPUOpenCVComplex()
{
    
}

int GPUOpenCVComplex::operator()(int x, int y) 
{ 
#if 0
    return std::sqrt(x*x + y*y);
#else
    // Some random opencv usage to test linkage:
    cv::Mat image(100, 100, CV_8UC1);
    cv::cvtColor(image, image, cv::COLOR_GRAY2BGR);
    return static_cast<int>(cv::norm(cv::Point(x, y))); // use this just to test dependency
#endif
}

_END_COMPLEX
