project(complex)
set(COMPLEX_SRCS complex.cpp)
set(COMPLEX_PUBLIC_HDRS complex.hpp PARENT_SCOPE)
set(COMPLEX_HDRS ${COMPLEX_PUBLIC_HDRS})
add_library(complex OBJECT ${COMPLEX_HDRS} ${COMPLEX_SRCS})




