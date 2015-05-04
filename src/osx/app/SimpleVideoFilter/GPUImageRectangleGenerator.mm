//
//  GPUImageRectangleGenerator.m
//  drishtisdk
//
//  Created by David Hirvonen on 4/4/15.
//
//

#import <Cocoa/Cocoa.h> // NOTE: This must come first, needed for some NS* definition

#import "GPUImageRectangleGenerator.h"

#import <Foundation/Foundation.h>

NSString *const kGPUImageLineGeneratorVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 
 void main()
 {
     gl_Position = position;
 }
 );

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageLineGeneratorFragmentShaderString = SHADER_STRING
(
 uniform lowp vec3 lineColor;
 
 void main()
 {
     gl_FragColor = vec4(lineColor, 1.0);
 }
 );
#else
NSString *const kGPUImageLineGeneratorFragmentShaderString = SHADER_STRING
(
 uniform vec3 lineColor;
 
 void main()
 {
     gl_FragColor = vec4(lineColor, 1.0);
 }
 );
#endif


@interface GPUImageRectangleGenerator()
{
    GLint m_PlanarUniformMVP;
    GLint m_PlanarUniformTexture;
    
    CGSize m_size;
    const GLfloat *m_textureCoordinates;
    const GLfloat *m_frameVertices;
}
@end

enum { ATTRIB_VERTEX, ATTRIB_TEXTUREPOSITION, NUM_ATTRIBUTES };

@implementation GPUImageRectangleGenerator

@synthesize H = _H;
@synthesize rectangles = _rectangles;
@synthesize lineWidth = _lineWidth;
@synthesize size = _size;


- (id)initWithSize:(CGSize)size
{
    if (!(self = [super initWithVertexShaderFromString:kGPUImageLineGeneratorVertexShaderString fragmentShaderFromString:kGPUImageLineGeneratorFragmentShaderString]))
    {
        return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        lineWidthUniform = [filterProgram uniformIndex:@"lineWidth"];
        lineColorUniform = [filterProgram uniformIndex:@"lineColor"];
        
        self.lineWidth = 4.0;
        [self setLineColorRed:0.0 green:1.0 blue:0.0];
    });
    
    return self;
}
        
// Source: dhirvonen@elucideye.com
// void MosaicRenderGL::draw( const cv::Mat &MVPt, const cv::Rect &roi, GLuint texture, GLuint unit )

- (void) draw:(const cv::Matx44f &)MVPt withRoi:(const cv::Rect &)roi texture:(GLint)texture andUnit:(GLint)unit
{
    (*m_pPlanarShaderProgram)();
    
    glActiveTexture(GL_TEXTURE0 + unit);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glUniform1i(m_PlanarUniformTexture, unit);
    glUniformMatrix4fv(m_PlanarUniformMVP, 1, 0, (GLfloat *)&MVPt(0,0));
    
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, m_frameVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXTUREPOSITION, 2, GL_FLOAT, 0, 0, m_textureCoordinates);
    glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITION);
    
    // Render to texture associated with currently bound RenderTexture::defaultFramebuffer
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


// Prevent rendering of the frame by normal means
- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    // Transform to rectangle defined by (-1,-1) (+1,+1)
    cv::Matx33f T(1,0,-_size.width/2,0,1,-_size.height/2,0,0,1), S(2.0/_size.width,0,0,0,2.0/_size.height,0,0,0,1);
    cv::Matx33f H = S * T;
    [self drawRectangles:_rectangles withTransform:H frameTime:kCMTimeInvalid];
}

- (void)setLineWidth:(CGFloat)newValue;
{
    _lineWidth = newValue;
    [GPUImageContext setActiveShaderProgram:filterProgram];
    glLineWidth(newValue);
}

- (void)setLineColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;
{
    GPUVector3 lineColor = {redComponent, greenComponent, blueComponent};
    
    [self setVec3:lineColor forUniform:lineColorUniform program:filterProgram];
}

// ((((((((((( Rectangle drawing )))))))))))

- (void)drawRectangles:(const std::vector<cv::Rect> &)rectangles withTransform:(const cv::Matx33f &)H frameTime:(CMTime)frameTime;
{
    if (self.preventRendering)
    {
        return;
    }
    
    // Iterate through and generate vertices from the slopes and intercepts
    [GPUImageContext useImageProcessingContext];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    GLint unit = GL_TEXTURE2;
    GLint texture = [firstInputFramebuffer texture];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    { // Draw blue tinted detection boxes:
        
        std::vector<cv::Point2f> vertices; // {-1,-1}, {1,-1}, {-1,1}, {1,1}
        for(const auto &e : rectangles)
        {
            [self setLineColorRed:0.0 green:0.0 blue:1.0];
            
            const auto &roi = e;
            cv::Point2f tr(roi.x + roi.width, roi.y), bl(roi.x, roi.y + roi.height);
            std::vector<cv::Point2f> points { bl, roi.br(), roi.tl(), tr }; // order for GL_TRIANGLE format
            for(auto &p : points)
            {
                cv::Point3f q = H * p;
                p = { q.x/q.z, q.y/q.z };
            }
            
            // first triangle of quad:
            vertices.push_back(points[0]);
            vertices.push_back(points[1]);
            vertices.push_back(points[2]);
            
            // second triangle of quad:
            vertices.push_back(points[1]);
            vertices.push_back(points[2]);
            vertices.push_back(points[3]);
        }
        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, &vertices[0]);
        glDrawArrays(GL_TRIANGLES, 0, vertices.size());
    }
 
    [firstInputFramebuffer unlock];
}
    
@end