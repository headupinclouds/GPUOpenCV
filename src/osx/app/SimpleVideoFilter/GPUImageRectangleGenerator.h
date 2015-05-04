//
//  GPUImageRectangleGenerator.h
//  drishtisdk
//
//  Created by David Hirvonen on 4/4/15.
//
//

#ifndef drishtisdk_GPUImageRectangleGenerator_h
#define drishtisdk_GPUImageRectangleGenerator_h

#define EXTERN_C_BEGIN extern "C" {
#define EXTERN_C_END }

EXTERN_C_BEGIN
#import "GPUImage/GPUImageFilter.h"
EXTERN_C_END

#include <opencv2/core/core.hpp>

@interface GPUImageRectangleGenerator : GPUImageFilter
{
    GLint lineWidthUniform, lineColorUniform;
}

// The width of the displayed lines, in pixels. The default is 1.
@property(readwrite, nonatomic) CGFloat lineWidth;
@property(readwrite, nonatomic) CGSize size; // detection image size
@property(readwrite, nonatomic) std::vector<cv::Rect> rectangles;
@property(readwrite, nonatomic) cv::Matx33f H;

- (id)initWithSize:(CGSize)size;

// The color of the lines is specified using individual red, green, and blue components (normalized to 1.0). The default is green: (0.0, 1.0, 0.0).
- (void)setLineColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;

// Drawing
- (void)drawRectangles:(const std::vector<cv::Rect> &)rectangles withTransform:(const cv::Matx33f &)H frameTime:(CMTime)frameTime;

@end

#endif
