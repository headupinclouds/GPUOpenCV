project (SimpleVideoFilter)

# Lineage:
#
# Source code taken from sample GPUImage ios Xcode project
#
# GPUImage/examples/iOS/SimpleVideoFilter/SimpleVideoFilter
#
# CMake stuff laboriously scrounged from various internet sources to enable Xcode generator
# build for iOS without mucking around with XCode manually.  I have a need for automatically
# generating simple ios applications (single view controller apps) via CMakeLists.txt.  This
# seems to be kind of supported, so I'm using this as a sample project to outline all of the
# steps required to achieve this.

include_directories("${CMAKE_SOURCE_DIR}/src/app/ios")

set (GPUOPENCV_SIMPLE_VIDEO_FILTER_SRCS
    main.m
    SimpleVideoFilterAppDelegate.h
    SimpleVideoFilterAppDelegate.mm
    SimpleVideoFilterViewController.h
    SimpleVideoFilterViewController.mm
    NativeVideoFrameHandler.h
    NativeVideoFrameHandler.mm
    ${CMAKE_SOURCE_DIR}/src/app/ios/UIImage+OpenCV.h
    ${CMAKE_SOURCE_DIR}/src/app/ios/UIImage+OpenCV.mm
)

set (RESOURCES SimpleVideoFilterViewController.xib)

#    en.lproj/MainStoryboard_iPhone.storyboard
#    SimpleVideoFilterViewController.xib
#    en.lproj
#    en.lproj/InfoPlist.strings
#    SimpleVideoFilter-Info.plist
#    SimpleVideoFilter-Prefix.pch

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -x objective-c++")

add_executable (SimpleVideoFilter MACOSX_BUNDLE ${GPUOPENCV_SIMPLE_VIDEO_FILTER_SRCS} ${RESOURCES} )

# http://stackoverflow.com/questions/7462129/cmake-xib-to-nib-compilation-for-ios-target
# SET_SOURCE_FILES_PROPERTIES(${RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set(PRODUCT_NAME SimpleVideoFilter)
set(EXECUTABLE_NAME SimpleVideoFilter)
set(APP_IDENTIFIER com.elucideye.SimpleVideoFilter)

# http://ebitg.wordpress.com/2012/04/24/cmake-iphone-support/
# http://stackoverflow.com/questions/18700901/ios-cmake-installtargets-function-uses-wrong-folders
# http://stackoverflow.com/questions/19325989/how-to-set-xcode-only-active-arch-flag-with-cmake

CONFIGURE_FILE("${CMAKE_CURRENT_LIST_DIR}/SimpleVideoFilter-Info.plist.in" "${CMAKE_CURRENT_BINARY_DIR}/${PROJ_NAME}.plist")

set_target_properties(SimpleVideoFilter PROPERTIES 
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/${PROJ_NAME}.plist"
    RESOURCE "${RESOURCES}"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer: David Hirvonen"
    ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}"
    XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "NO"
)

message("LIBS: ${GPUImage_LIB} ${OpenCV_LIBS}")
target_link_libraries(SimpleVideoFilter GPUOpenCV ${GPUIMAGE_LIB} ${OpenCV_LIBS})

#https://github.com/phaser/tests/blob/master/TestGame/dev/CMakeLists.txt
ADD_FRAMEWORK( QuartzCore SimpleVideoFilter )
ADD_FRAMEWORK( ImageIO SimpleVideoFilter )
ADD_FRAMEWORK( CoreGraphics SimpleVideoFilter )
ADD_FRAMEWORK( CoreVideo SimpleVideoFilter )
ADD_FRAMEWORK( CoreMedia SimpleVideoFilter )
ADD_FRAMEWORK( CoreLocation SimpleVideoFilter )
ADD_FRAMEWORK( AVFoundation SimpleVideoFilter )
ADD_FRAMEWORK( GLKit SimpleVideoFilter )
ADD_FRAMEWORK( Accelerate SimpleVideoFilter )
ADD_FRAMEWORK( OpenGLES SimpleVideoFilter )
ADD_FRAMEWORK( UIKit SimpleVideoFilter )

# ADD_FRAMEWORK( AssetsLibrary SimpleVideoFilter )
# ADD_FRAMEWORK( CoreMotion SimpleVideoFilter )

macro(ADD_LOCAL_FRAMEWORK fwname appname fwpath )
  find_library(FRAMEWORK_${fwname}
    NAMES ${fwname}
    PATHS ${fwpath}
    PATH_SUFFIXES Frameworks
    NO_DEFAULT_PATH)
  if( ${FRAMEWORK_${fwname}} STREQUAL FRAMEWORK_${fwname}-NOTFOUND)
    MESSAGE(ERROR ": Framework ${fwname} not found")
  else()
    TARGET_LINK_LIBRARIES(${appname} "${FRAMEWORK_${fwname}}/${fwname}")
    MESSAGE(STATUS "Framework ${fwname} found at ${FRAMEWORK_${fwname}}")
  endif()
endmacro(ADD_LOCAL_FRAMEWORK)

# Try to include the framework directly and then via the symbolic link

# I'd like to be able to point ADD_FRAMEWORK to my own framework location:
#
# ADD_FRAMEWORK( opencv2 SimpleVideoFilter ${CMAKE_SOURCE_DIR}/prebuilt/ios )
# ADD_FRAMEWORK( GPUImage SimpleVideoFilter ${CMAKE_OSX_SYSROOT}/prebuilt/ios )
#
# but can't seem to find the right syntax
#
# To get this macro working I had to symbolically link these frameworks (ugly):
#
# ln -s opencv2.framework /Applications/Xcode.app//Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/
# ln -s GPUImage.framework /Applications/Xcode.app//Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/

# Note: Instead of this we'll use the newly added (ios friendly) hunter support for GPUImage and opencv2
# See: target_link_libraries above
#ADD_FRAMEWORK( opencv2 SimpleVideoFilter ${CMAKE_OSX_SYSROOT}/System/Library )
#ADD_FRAMEWORK( GPUImage SimpleVideoFilter ${CMAKE_OSX_SYSROOT}/System/Library )











