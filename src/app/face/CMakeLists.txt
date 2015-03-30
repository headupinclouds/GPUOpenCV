add_executable ( dbt_face_detection  dbt_face_detection.cpp )
target_link_libraries ( dbt_face_detection ${OpenCV_LIBS} )
install(TARGETS dbt_face_detection DESTINATION bin)
