set( DBT_SRCS detection_based_tracker.hpp detection_based_tracker.cpp ) 

add_executable ( dbt_face_detection  dbt_face_detection.cpp ${DBT_SRCS} )
target_link_libraries ( dbt_face_detection ${OpenCV_LIBS} )
install(TARGETS dbt_face_detection DESTINATION bin)
configure_file(dbt_face_detection.sh dbt_face_detection.sh COPYONLY)  # ln -s instead
