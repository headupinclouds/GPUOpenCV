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

cmake_minimum_required(VERSION 2.8.11)
project (SimpleVideoFilter)

include("$ENV{SUGAR_ROOT}/cmake/Sugar")
include(sugar_include) # <= not used?

sugar_include("./")
set (RESOURCES Base.lproj/MainMenu.xib SLSSimpleVideoFilterWindowController.xib)

if(NOT XCODE_VERSION)
  sugar_fatal_error("Xcode only")
endif()

#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -x objective-c")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -x objective-c++")

set(PRODUCT_NAME SimpleVideoFilter)
set(EXECUTABLE_NAME SimpleVideoFilter)
set(APP_IDENTIFIER com.elucideye.SimpleVideoFilter)

add_executable (SimpleVideoFilter MACOSX_BUNDLE ${SOURCES} ${RESOURCES} )

set_target_properties(
  SimpleVideoFilter
  PROPERTIES
  MACOSX_BUNDLE YES
  MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_LIST_DIR}/Info.plist.in"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
  XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2" # Universal (iPad + iPhone)
  # http://stackoverflow.com/a/20982506/2288008
  XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
  XCODE_ATTRIBUTE_INSTALL_PATH "${CMAKE_BINARY_DIR}/ProductRelease"
  # By default this setting is empty =>
  # archives not showing up in Xcode organizer.
  # http://stackoverflow.com/a/8102602/2288008
  XCODE_ATTRIBUTE_COMBINE_HIDPI_IMAGES "NO" # If this setting is "YES"
  # application can't pass archive validation.
  # http://stackoverflow.com/a/24040412/2288008
  RESOURCE "${RESOURCES}"
)

set_target_properties(
  SimpleVideoFilter
  PROPERTIES
  XCODE_ATTRIBUTE_PRODUCT_NAME
  "SimpleVideoFilter"
  XCODE_ATTRIBUTE_BUNDLE_IDENTIFIER
  "com.elucideye.SimplevideoFilter"
)

set_target_properties(
  SimpleVideoFilter
  PROPERTIES
  XCODE_ATTRIBUTE_PRODUCT_NAME[variant=Debug]
  "SimpleVideoFilter-Dbg"
  XCODE_ATTRIBUTE_BUNDLE_IDENTIFIER[variant=Debug]
  "com.elucideye.SimpleVideoFilter"
  )

message( "OpenCV_LIBS  ${OpenCV_LIBS}" )
message( "GPUImage::gpuimage GPUImage::gpuimage" )

target_link_libraries(
  SimpleVideoFilter
  GPUOpenCV
  GPUImage::gpuimage
  ${OpenCV_LIBS}
  "-framework CoreGraphics"
  "-framework Foundation"
  "-framework QuartzCore"
  "-framework ImageIO"
  "-framework CoreGraphics"
  "-framework CoreVideo"
  "-framework CoreMedia"
  "-framework CoreLocation" 
  "-framework AVFoundation"
  "-framework GLKit"
  "-framework Accelerate"
  "-framework OpenGL"
  )







