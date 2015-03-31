# GPUOpenCV

Sample repository for experimenting with hunter to combine multiple packages (in this case OpenCV and GPUImage)

As of: Tue Mar 31 00:31:22 EDT 2015

cmake -H. -B_builds -DHUNTER_STATUS_DEBUG=ON

Will make a functioning build tree on OS X.  I.e, you can:

cd _builds/src/app/batch_process
bash -fx ./batch_process.sh 

To run a simple laplacian batch test

Also the iOS SimpleVideoFilter app will run using the polly build script 
build.py --toolchain ios-8-2 --verbose --open

TODO: Need to bootstrap polly installation using the huntergate setup.  
