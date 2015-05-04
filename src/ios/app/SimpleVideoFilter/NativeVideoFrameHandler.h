//
//  NativeVideoFrameHandler.h
//  GPUOpenCV
//
//  Created by David Hirvonen on 3/29/15.
//
//

#ifndef GPUOpenCV_NativeVideoFrameHandler_h
#define GPUOpenCV_NativeVideoFrameHandler_h

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImageVideoCamera.h>

@interface NativeVideoFrameHandler : NSObject <GPUImageVideoCameraDelegate>
{
    
}
@property(readwrite, nonatomic) CMSampleBufferRef frame;
+ (UIImage*) getUIImageFromBuffer:(CMSampleBufferRef) sampleBuffer;
+ (UIImage*) getUIImageFromYuvBuffer: (CMSampleBufferRef) sampleBuffer;
+ (UIImage*) getUIImageFromYuImagevBuffer: (CVImageBufferRef) imageBuffer;
- (id)init;
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end


#endif
