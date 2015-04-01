add_executable ( test_cvmatio test_cvmatio.cpp )
target_link_libraries ( test_cvmatio ${OpenCV_LIBS} ${CVMATIO_LIBS} )
install(TARGETS test_cvmatio DESTINATION bin)
configure_file(test_cvmatio.sh test_cvmatio.sh COPYONLY)  # ln -s instead
