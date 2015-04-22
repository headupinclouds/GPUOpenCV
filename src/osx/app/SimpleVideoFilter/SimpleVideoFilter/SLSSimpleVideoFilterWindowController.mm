#import "SLSSimpleVideoFilterWindowController.h"

#import <GPUImage/GPUImageHoughTransformLineDetector.h>

#import "GPUImage/GPUImageRawDataInput.h"
#import "GPUImage/GPUImageRawDataOutput.h"
#import "GPUImage/GPUImageAlphaBlendFilter.h"

//#import "GPUImageRectangleGenerator.h"

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>

// This code retrieves dimensions for a configured AVCaptureSesssion:
// http://cocoatouch.blog138.fc2.com/blog-entry-203.html

@implementation AVCaptureSession (GetDimensions)
-(CMVideoDimensions)dimensions
{
    AVCaptureInput *input = [self.inputs objectAtIndex:0];
    AVCaptureInputPort *port = [input.ports objectAtIndex:0];
    CMFormatDescriptionRef formatDescription = port.formatDescription;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    return dimensions;
}
@end

static CGSize GPUImageConvert(const cv::Size &size) { return CGSizeMake(size.width, size.height); }

@interface SLSSimpleVideoFilterWindowController ()
{
    GPUImageRawDataInput *rawIn;
    GPUImageRawDataOutput *rawOut;

    cv::Size frameSize;
    cv::Mat4b input;
    cv::Mat image, I;

    GPUImageAlphaBlendFilter *blendFilter;
}
@end

@implementation SLSSimpleVideoFilterWindowController

- (int) detect
{
    return 0;
}

#if 1

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    // Allocate the face detector
    GPUImageView *filterView = self.videoView;
    
    // Instantiate video camera
    videoCamera = [[GPUImageAVCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraDevice:nil];
    videoCamera.runBenchmark = YES;
    
    CMVideoDimensions dimensions = [videoCamera.captureSession dimensions];
    NSLog(@"dimensions : %dw , %dh", dimensions.width,dimensions.height);
    
    frameSize.width = dimensions.width;
    frameSize.height = dimensions.height;
    
    glDepthMask(GL_FALSE);
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DITHER);
    
    filter= [[GPUImageFilter alloc] init];
    [videoCamera addTarget:filter];
    
    // (((((( GPU => CPU ))))))
    rawOut = [[GPUImageRawDataOutput alloc] initWithImageSize:GPUImageConvert(self->frameSize) resultsInBGRAFormat:YES];
    __weak GPUImageRawDataOutput *weakOut = rawOut;
    rawOut.enabled = YES;
    [filter addTarget:rawOut];
    
#if DO_CPU_DRAWING
    // (((((( CPU => GPU ))))))
    std::vector<GLubyte> bytes( self->frameSize.area() * 4 );
    rawIn =  [[GPUImageRawDataInput alloc] initWithBytes:&bytes[0] size:GPUImageConvert(self->frameSize)];
    __weak GPUImageRawDataInput *weakIn = rawIn;
    [rawIn addTarget:filterView];
#endif
    
    [filter addTarget:filterView];

    // Creaate weak references to avoid circular reference inside block/closure:
    __weak SLSSimpleVideoFilterWindowController *weakSelf = self;

    // write low res grayscale image to alpha channel of full res color image
    //[[UIScreen mainScreen] setBrightness:1.0];
    
    [rawOut setNewFrameAvailableBlock:^
     {
         __strong  SLSSimpleVideoFilterWindowController *strongSelf = weakSelf;
         __strong GPUImageRawDataOutput *strongOut = weakOut;
         
         // NSLog(@"seconds = %f", CMTimeGetSeconds(strongSelf->frameTime));
         
         [strongOut lockFramebufferForReading];
         GLubyte *ptr = [strongOut rawBytesForImage];
         if(ptr != NULL)
         {
             strongSelf->input = cv::Mat4b( strongSelf->frameSize.height, strongSelf->frameSize.width, reinterpret_cast<cv::Vec4b*>(ptr), [strongOut bytesPerRowInOutput] );
	     [strongSelf detect];

#if DO_CPU_DRAWING
             // Draw something to prove the data has really round tripped from the GPU:

             cv::rectangle(strongSelf->input, {0,0,100,100}, {0,255,0}, 4, 8);

             __strong GPUImageRawDataInput *strongIn = weakIn;
             
             // Use this to upload CPU processed images
             CGSize canvasSize = CGSizeMake(strongSelf->input.cols, strongSelf->input.rows);
             [strongIn forceProcessingAtSize:canvasSize];
             [strongIn updateDataFromBytes:strongSelf->input.ptr() size:GPUImageConvert(strongSelf->input.size())];
             [strongIn processData];
#else
	
		// TODO: Add GPU drawing
#endif
    
         }
         [strongOut unlockFramebufferAfterReading];
     }];
    
    self.videoView.fillMode = kGPUImageFillModePreserveAspectRatio;
    
    // Start capturing
    [videoCamera startCameraCapture];
}

#else

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    CGSize frameSize;
    frameSize.width = 640;
    frameSize.height = 480;
    
    // Instantiate video camera
    videoCamera = [[GPUImageAVCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraDevice:nil];
    videoCamera.runBenchmark = YES;
    
    GPUImageHoughTransformLineDetector *ht = [[GPUImageHoughTransformLineDetector alloc] init];
    [videoCamera addTarget:ht];
    ht.edgeThreshold = 0.5;
    ht.lineDetectionThreshold = 0.5;
    
    //filter = ht;
    
    GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
    [lineGenerator forceProcessingAtSize:frameSize];
    [lineGenerator setLineColorRed:0.0 green:1.0 blue:0.0];
    lineGenerator.lineWidth = 20.0;
    
    [ht setLinesDetectedBlock:^(GLfloat* lineArray, NSUInteger linesDetected, CMTime frameTime){
        [lineGenerator renderLinesFromArray:lineArray count:linesDetected frameTime:frameTime];
    }];
    
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    [blendFilter forceProcessingAtSize:frameSize];
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc] init];
    [videoCamera addTarget:gammaFilter];
    [gammaFilter addTarget:blendFilter];
    [lineGenerator addTarget:blendFilter];

    [blendFilter addTarget:self.videoView];
    
    self.videoView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [filter addTarget:self.videoView];
    
    // Start capturing
    [videoCamera startCameraCapture];
}


#endif


@end
