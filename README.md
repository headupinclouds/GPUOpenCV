#
# GPUOpenCV
#

A simple repository for experimenting with ruslo's hunter and polly CMake dependency/package managers.  
This is also a testbed for working through a number of other CMake basics I've done somehwat haphazardly in the past.
I intend to use this as a starting point for my future projects.  Here are the main goals:

* provide cmake options to build the internal project code as a static lib, shared lib w/ versionining, or as a framework (iOS/OS X)
* provide some sample OpenCV console apps for a quick start approach to cross platform OpenCV development
* create an iOS application and XCode project from source using OpenCV and GPUImage via CMake's XCode generator and an ios toolchain
* provide cmake options for linking to frameworks (using find_library) in non-standard locations
 (still working on this and relying on symlinks to frameworks in the "standard" CMAKE_OSX_SYSROOT location)

TODO: ...
