add_executable ( test_cvmatio test_cvmatio.cpp )
target_link_libraries ( test_cvmatio ${OpenCV_LIBS} ${CVMATIO_LIB} )
install(TARGETS test_cvmatio DESTINATION bin)
configure_file(a.mat a.mat COPYONLY)
configure_file(test_cvmatio.sh test_cvmatio.sh COPYONLY)  # ln -s instead
