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

Currently the iOS platform GPUImage and OpenCV dependencies rely on prebuilt frameworks.  
These don't use vanilla CMake builds and will require a little more CMake magic to get 
working properly.  some more work to get hunter.cmake pages configured.

You will need to checkout the [headupinclouds/hunter](https://github.com/headupinclouds/hunter) fork of
[ruslo/hunter](https://github.com/ruslo/hunter) for the new package definitions (i.e., OpenCV, cvmatio, etc) 
until those can be pushed back.

see: git@github.com:headupinclouds/hunter.git

You will need to checkout the [headupinclouds/polly](https://github.com/headupinclouds/polly) fork of
[ruslo/polly](https://github.com/ruslo/polly) for the new package toolchain (i.e., ios-8-2)
until those can be pushed back.

see: git@github.com:headupinclouds/polly.git

Sample repository for experimenting with hunter to combine multiple packages (in this case OpenCV and GPUImage)

Then update your environment variables appropriately:
```
export HUNTER_ROOT=${HOME}/your_devel_path/hunter
export POLLY_ROOT=${HOME}/your_devel_path/polly
export SUGAR_ROOT=${HOME}/your_devel_path/sugar
export PATH=${POLLY_ROOT}/bin:${PATH}
```

Alternatively you can just copy the the very few changes over if you already have ruslo/{hunter,polly} installed.

### Command line sample for building shared libs ###
build.py --toolchain libcxx --verbose --install --clear  | grep Installing | sed "s|${PWD}||g"
-- Installing: _install/libcxx/bin/dbt_face_detection
-- Installing: _install/libcxx/bin/batch_process
-- Installing: _install/libcxx/bin/test_cvmatio
-- Installing: _install/libcxx/bin/test_gpuopencv
-- Installing: _install/libcxx/lib/libGPUOpenCV.1.0.0.dylib
-- Installing: _install/libcxx/lib/libGPUOpenCV.1.dylib
-- Installing: _install/libcxx/lib/libGPUOpenCV.dylib
-- Installing: _install/libcxx/include/GPUOpenCV/complex.hpp
-- Installing: _install/libcxx/include/GPUOpenCV/simple.hpp
-- Installing: _install/libcxx/include/GPUOpenCV/master.hpp

### Command line sample for building static libraries ###
build.py --toolchain libcxx --verbose --fwd "ENABLE_GPUOPENCV_SHARED=OFF" --install --clear | grep Installing | sed "s|${PWD}/||g"
-- Installing: _install/libcxx/bin/dbt_face_detection
-- Installing: _install/libcxx/bin/batch_process
-- Installing: _install/libcxx/bin/test_cvmatio
-- Installing: _install/libcxx/bin/test_gpuopencv
-- Installing: _install/libcxx/lib/libGPUOpenCV.a
-- Installing: _install/libcxx/include/GPUOpenCV/complex.hpp
-- Installing: _install/libcxx/include/GPUOpenCV/simple.hpp
-- Installing: _install/libcxx/include/GPUOpenCV/master.hpp

### Command line sample for building framework ###
build.py --toolchain libcxx --verbose --fwd "BUILD_FRAMEWORK=ON" --install --clear | grep Installing | sed "s|${PWD}/||g"
-- Installing: _install/libcxx/bin/dbt_face_detection
-- Installing: _install/libcxx/bin/batch_process
-- Installing: _install/libcxx/bin/test_cvmatio
-- Installing: _install/libcxx/bin/test_gpuopencv
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/GPUOpenCV
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/Headers
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/Resources
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/Versions
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/Versions/1.0.0
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/Versions/1.0.0/GPUOpenCV
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/Versions/1.0.0/Headers
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/Versions/1.0.0/Headers/master.hpp
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/Versions/1.0.0/Resources
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/Versions/1.0.0/Resources/Info.plist
-- Installing: _install/libcxx/Library/Frameworks/GPUOpenCV.framework/Versions/Current

And then a simple test via:

install/libcxx/bin/test_gpuopencv 
test_gpuopencv: 3

