add_executable ( batch_process batch_process.cpp batch_process )
target_link_libraries ( batch_process ${OpenCV_LIBS} )
install(TARGETS batch_process DESTINATION bin)
configure_file(batch_process.sh batch_process.sh COPYONLY)  # ln -s instead
