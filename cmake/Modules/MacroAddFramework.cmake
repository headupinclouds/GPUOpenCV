macro(ADD_FRAMEWORK fwname appname)
  find_library(FRAMEWORK_${fwname}
    NAMES ${fwname}
    PATHS ${CMAKE_OSX_SYSROOT}/System/Library /Library
    PATH_SUFFIXES Frameworks)
  if( ${FRAMEWORK_${fwname}} STREQUAL FRAMEWORK_${fwname}-NOTFOUND)
    MESSAGE(ERROR ": Framework ${fwname} not found")
  else()
    TARGET_LINK_LIBRARIES(${appname} "${FRAMEWORK_${fwname}}/${fwname}")
    #target_link_libraries(${appname} "-framework opencv2")
    #set_target_properties(${appname} PROPERTIES LINK_FLAGS "-Wl,-F/Library/Frameworks")
    MESSAGE(STATUS "Framework ${fwname} found at ${FRAMEWORK_${fwname}}")
  endif()
endmacro(ADD_FRAMEWORK)