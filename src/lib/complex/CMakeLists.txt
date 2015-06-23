set(SRCS complex.cpp)
set(HDRS_PUBLIC complex.hpp)
set(HDRS ${HDRS_PUBLIC})
add_library(complex OBJECT ${HDRS} ${SRCS})

## make path valid for parent
for_each_prepend(COMPLEX_PUBLIC_HDRS ${CMAKE_CURRENT_SOURCE_DIR} ${HDRS_PUBLIC}) 
set(COMPLEX_PUBLIC_HDRS ${COMPLEX_PUBLIC_HDRS} PARENT_SCOPE) # export to parent scope

