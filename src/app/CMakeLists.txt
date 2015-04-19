if(is_ios)
	add_subdirectory(test_opencv)       # test our opencv library
	add_subdirectory(SimpleVideoFilter) # test our ios project createion
else()
	add_subdirectory(face)           # test opencv dependencies
	add_subdirectory(batch_process)  # test opencv dependencies
	add_subdirectory(test_cvmatio)   # test cvmatio hunter package
	add_subdirectory(test_gpuopencv) # test our internal lib
endif()

