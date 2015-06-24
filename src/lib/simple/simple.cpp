#include "simple/simple.hpp"
#include "simple/simple_private.hpp"

#if TEST_SCOPE_ISSUE
  // Now test a LIB::LIB library
  #include <boost/filesystem.hpp>
  #include <iostream> // std::cout
#endif

_BEGIN_SIMPLE

GPUOpenCVSimple::GPUOpenCVSimple()
{
#if TEST_SCOPE_ISSUE
  namespace fs = boost::filesystem;
  std::cout << "Current path: " << fs::current_path() << std::endl;    
#endif
}

int GPUOpenCVSimple::operator()(int x, int y) 
{ 
    return simple_private_add(x, y);
}

_END_SIMPLE
