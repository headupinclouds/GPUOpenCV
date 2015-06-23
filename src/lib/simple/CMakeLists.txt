set(SRCS simple.cpp simple_private.cpp)
set(HDRS_PUBLIC simple.hpp)
set(HDRS ${HDRS_PUBLIC} simple_private.hpp)
add_library(simple OBJECT ${HDRS} ${SRCS})

## make path valid for parent
for_each_prepend(SIMPLE_PUBLIC_HDRS ${CMAKE_CURRENT_SOURCE_DIR} ${HDRS_PUBLIC}) 
set(SIMPLE_PUBLIC_HDRS ${SIMPLE_PUBLIC_HDRS} PARENT_SCOPE) # export to parent scope


