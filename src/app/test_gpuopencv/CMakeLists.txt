add_executable(test_gpuopencv test_gpuopencv.cpp)
target_link_libraries(test_gpuopencv GPUOpenCV)
install(TARGETS test_gpuopencv DESTINATION bin)
configure_file(test_gpuopencv.sh test_gpuopencv.sh COPYONLY)  # ln -s instead
