#
# GPUOpenCV
#

Sample repository for experimenting with hunter to combine multiple packages (in this case OpenCV and GPUImage)

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




