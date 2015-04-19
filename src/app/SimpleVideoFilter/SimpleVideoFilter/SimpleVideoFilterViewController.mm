#import "SimpleVideoFilterViewController.h"
#import "NativeVideoFrameHandler.h"
#import "UIImage+OpenCV.h"

#import "GPUImage/GPUImageRawDataInput.h"
#import "GPUImage/GPUImageRawDataOutput.h"
#import "GPUImage/GPUImageShiTomasiFeatureDetectionFilter.h"

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#define DO_CPU_TO_GPU 1

@interface SimpleVideoFilterViewController()
{
    GPUImageRawDataInput *rawIn;
    GPUImageRawDataOutput *rawOut;
    NativeVideoFrameHandler *nativeFrameHandler;
    
    bool useGPUInput;
    cv::Mat4b input;
    cv::Mat4b output;
    cv::Size frameSize;
}
@end

static CGSize GPUImageConvert(const cv::Size &size)
{
    return CGSizeMake(size.width, size.height);
}

@implementation SimpleVideoFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle


typedef cv::Mat (^ FrameHandlerType)();

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    nativeFrameHandler = [[NativeVideoFrameHandler alloc] init];
    
    FrameHandlerType frameHandlerDelegate = ^()
    {
        cv::Mat image;
        if(nativeFrameHandler && nativeFrameHandler.frame)
        {
            UIImage *frame = [NativeVideoFrameHandler getUIImageFromYuvBuffer:nativeFrameHandler.frame];
            if(frame)
            {
                image = frame.CVGrayscaleMat;
            }
        }
        return image;
    };
    
    
    filterView = (GPUImageView *)self.view;
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    videoCamera.delegate = nativeFrameHandler;
    
    {
        // http://stackoverflow.com/questions/18563259/avcapturesession-image-dimensions-with-gpuimage
        AVCaptureVideoDataOutput *dataOutput = [[[videoCamera captureSession] outputs] lastObject];
        NSDictionary* outputSettings = [dataOutput videoSettings];
        frameSize.width = [[outputSettings objectForKey:@"Width"]  longValue];
        frameSize.height = [[outputSettings objectForKey:@"Height"] longValue];
        if (UIInterfaceOrientationIsPortrait([videoCamera outputImageOrientation]))
            std::swap(frameSize.width, frameSize.height);
    }
    
    // ((((((((( Disable unused OpenGL ES 2.0 features )))))))))
    glDepthMask(GL_FALSE);
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DITHER);
    
    filter = [[GPUImageSepiaFilter alloc] init];
    //filter = [[GPUImageShiTomasiFeatureDetectionFilter alloc] init];
    
    [videoCamera addTarget:filter];
    
    // (((((( GPU => CPU ))))))
    rawOut = [[GPUImageRawDataOutput alloc] initWithImageSize:GPUImageConvert(frameSize) resultsInBGRAFormat:YES];
    rawOut.enabled = YES;
    [filter addTarget:rawOut];
    
    // (((((( CPU => GPU ))))))
    std::vector<GLubyte> bytes( frameSize.area() * 4 );
    rawIn =  [[GPUImageRawDataInput alloc] initWithBytes:&bytes[0] size:GPUImageConvert(frameSize)];
    [rawIn addTarget:filterView];
    
    // Creaate weak references to avoid circular reference inside block/closure:
    __weak SimpleVideoFilterViewController *weakSelf = self;
    __weak GPUImageRawDataOutput *weakOut = rawOut;
    __weak GPUImageRawDataInput *weakIn = rawIn;
    
    // write low res grayscale image to alpha channel of full res color image
    //[[UIScreen mainScreen] setBrightness:1.0];
    
    [rawOut setNewFrameAvailableBlock:^
     {
         __strong  SimpleVideoFilterViewController *strongSelf = weakSelf;
         __strong GPUImageRawDataOutput *strongOut = weakOut;
         
         // NSLog(@"seconds = %f", CMTimeGetSeconds(strongSelf->frameTime));
         
         [strongOut lockFramebufferForReading];
         GLubyte *ptr = [strongOut rawBytesForImage];
         if(ptr != NULL)
         {
             strongSelf->input = cv::Mat4b( strongSelf->frameSize.height, strongSelf->frameSize.width, reinterpret_cast<cv::Vec4b*>(ptr), [strongOut bytesPerRowInOutput] );
             strongSelf->input.copyTo(strongSelf->output); // just for testing
             
             // Draw something to prove the data has really round tripped from the GPU
             cv::Mat &canvas = strongSelf->output;
             cv::circle(canvas, {canvas.cols/2, canvas.rows/2}, canvas.cols/4, {0,255,0}, 4, CV_AA);

	// Add some temporary stuff to check the ios-8-2 polly toolchain
#if __cplusplus == 201103L 
	std::cout << "HAS C++11 : " << __cplusplus << std::endl;
#else if __cplusplus == 199711L
	ERROR_ONLY_CPP98
#else
	ERROR_OLD_CPP
#endif
             
             __strong GPUImageRawDataInput *strongIn = weakIn;
             
             // Use this to upload CPU processed images
             CGSize canvasSize = CGSizeMake(strongSelf->output.cols, strongSelf->output.rows);
             [strongIn forceProcessingAtSize:canvasSize];
             [strongIn updateDataFromBytes:strongSelf->output.ptr() size:GPUImageConvert(strongSelf->output.size())];
             [strongIn processData];
         }
         [strongOut unlockFramebufferAfterReading];
     }];
    
    
    [videoCamera startCameraCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Map UIDeviceOrientation to UIInterfaceOrientation.
    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
            orient = UIInterfaceOrientationLandscapeLeft;
            break;

        case UIDeviceOrientationLandscapeRight:
            orient = UIInterfaceOrientationLandscapeRight;
            break;

        case UIDeviceOrientationPortrait:
            orient = UIInterfaceOrientationPortrait;
            break;

        case UIDeviceOrientationPortraitUpsideDown:
            orient = UIInterfaceOrientationPortraitUpsideDown;
            break;

        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            // When in doubt, stay the same.
            orient = fromInterfaceOrientation;
            break;
    }
    videoCamera.outputImageOrientation = orient;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; // Support all orientations.
}

- (IBAction)updateSliderValue:(id)sender
{
    [(GPUImageSepiaFilter *)filter setIntensity:[(UISlider *)sender value]];
}

@end
