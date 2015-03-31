
if(is_ios)
	add_subdirectory(SimpleVideoFilter)
else()
	add_subdirectory(face)
	add_subdirectory(batch_process)
endif()

