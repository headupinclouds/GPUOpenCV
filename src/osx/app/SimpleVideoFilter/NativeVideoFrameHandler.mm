//
//  NativeVideoFrameHandler.m
//  GPUOpenCV
//
//  Created by David Hirvonen on 3/29/15.
//
//

#import "NativeVideoFrameHandler.h"
#import <ImageIO/ImageIO.h>
#import <Endian.h>

#include <vector>
#include <iostream>

static UIImage * makeGrayImageFromBytes(GLubyte *buffer, int width, int height, int stride, BOOL keep)
{
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(buffer, width, height, 8, width, colorSpaceRef, kCGBitmapByteOrderDefault);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    return myImage;
}

@interface NativeVideoFrameHandler()
{
    
}
@end

@implementation NativeVideoFrameHandler

@synthesize frame = _frame;

- (id)init
{
    if ((self = [super init]))
    {
        // do stuff
    }
    return self;
}

// http://stackoverflow.com/questions/6468535/cvpixelbufferlockbaseaddress-why-capture-still-image-using-avfoundation
+(UIImage*) getUIImageFromRGBBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    OSType pixelType = CVPixelBufferGetPixelFormatType(imageBuffer);
    
    // Create a bitmap graphics context with the sample buffer data
    CGBitmapInfo info = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, info);
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

// http://stackoverflow.com/questions/8838481/kcvpixelformattype-420ypcbcr8biplanarfullrange-frame-to-uiimage-conversion
+ (UIImage*) getUIImageFromYuvImageBuffer: (CVImageBufferRef) imageBuffer
{
    OSType type = CVPixelBufferGetPixelFormatType( imageBuffer ); // kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    uint8_t *baseAddress = (uint8_t *) CVPixelBufferGetBaseAddress(imageBuffer);
    CVPlanarPixelBufferInfo_YCbCrBiPlanar *bufferInfo = (CVPlanarPixelBufferInfo_YCbCrBiPlanar *)baseAddress;
    
    NSUInteger yOffset = EndianU32_BtoN(bufferInfo->componentInfoY.offset);
    NSUInteger yPitch = EndianU32_BtoN(bufferInfo->componentInfoY.rowBytes);
    
    uint8_t *yBuffer = baseAddress + yOffset;
#if 0
    NSUInteger cbCrOffset = EndianU32_BtoN(bufferInfo->componentInfoCbCr.offset);
    NSUInteger cbCrPitch = EndianU32_BtoN(bufferInfo->componentInfoCbCr.rowBytes);
    
    uint8_t *rgbBuffer = malloc(width * height * 3);
    uint8_t *cbCrBuffer = baseAddress + cbCrOffset;
    
    for(int y = 0; y < height; y++)
    {
        uint8_t *rgbBufferLine = &rgbBuffer[y * width * 3];
        uint8_t *yBufferLine = &yBuffer[y * yPitch];
        uint8_t *cbCrBufferLine = &cbCrBuffer[(y >> 1) * cbCrPitch];
        
        for(int x = 0; x < width; x++)
        {
            uint8_t y = yBufferLine[x];
            uint8_t cb = cbCrBufferLine[x & ~1];
            uint8_t cr = cbCrBufferLine[x | 1];
            
            uint8_t *rgbOutput = &rgbBufferLine[x*3];
            
            // from ITU-R BT.601, rounded to integers
            rgbOutput[0] = (298 * (y - 16) + 409 * cr - 223) >> 8;
            rgbOutput[1] = (298 * (y - 16) + 100 * cb + 208 * cr + 136) >> 8;
            rgbOutput[2] = (298 * (y - 16) + 516 * cb - 277) >> 8;
        }
    }
#else
    std::vector<uint8_t> bytes(width * height);
    for(int y = 0; y < height; y++)
    {
        uint8_t *yBufferLine = &yBuffer[y * yPitch];
        memcpy(&bytes[y*width], yBufferLine, width);
    }
    
    UIImage *image = makeGrayImageFromBytes(&bytes[0], width, height, width, YES);
#endif
    
    CVPixelBufferUnlockBaseAddress( imageBuffer, 0 );
    
    return image;
}

+ (UIImage*) getUIImageFromYuvBuffer: (CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    return [NativeVideoFrameHandler getUIImageFromYuvImageBuffer:imageBuffer];
}


- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    _frame = sampleBuffer; // hold on to this for later
    
    //drishti::glCheckError();
    //self.quaternion = [self getLatestQuaternion];
    
    // => http://stackoverflow.com/questions/5125323/problem-setting-exif-data-for-an-image
    // => http://stackoverflow.com/questions/8264804/storing-arbitrary-metadata-in-quicktime-file-via-avcapturemoviefileoutput-avmu
    CFDictionaryRef exifDictRef = (CFDictionaryRef)CMGetAttachment(sampleBuffer,kCGImagePropertyExifDictionary, NULL);
    NSDictionary *exifDict = (__bridge NSDictionary *)exifDictRef;
        // [((NSNumber *)[exifDict objectForKey:(__bridge id)kCGImagePropertyExifWhiteBalance]) doubleValue];
    // [((NSNumber *)[exifDict objectForKey:(__bridge id)kCGImagePropertyExifShutterSpeedValue]) doubleValue];
    // [[exifDict objectForKey:(__bridge id)kCGImagePropertyExifBrightnessValue] doubleValue];
    // [[exifDict objectForKey:(__bridge id)kCGImagePropertyExifApertureValue] doubleValue];
    // [[exifDict objectForKey:(__bridge id)kCGImagePropertyExifFNumber] doubleValue];
    // [[[exifDict objectForKey:(__bridge id)kCGImagePropertyExifISOSpeedRatings] objectAtIndex:0] doubleValue];
    // [[exifDict objectForKey:(__bridge id)kCGImagePropertyExifFocalLength] doubleValue];
    // [[exifDict objectForKey:(__bridge id)kCGImagePropertyExifFocalLenIn35mmFilm] doubleValue];
    // [[exifDict objectForKey:(__bridge id)kCGImagePropertyExifPixelXDimension] doubleValue];
    // [[exifDict objectForKey:(__bridge id)kCGImagePropertyExifPixelYDimension] doubleValue];
    
#if 0
    for (id key in exifDict)
        NSLog(@"key = %@, value = %@",key,[exifDict objectForKey:key]);
#endif

}

@end
