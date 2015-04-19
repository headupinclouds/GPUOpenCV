// Copyright (c) 2013, Ruslan Baratov
// All rights reserved.

#import "ViewController.hpp"
#import "UIImage+OpenCV.h"

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/imgproc/imgproc_c.h>

#include <iostream>

@interface ViewController ()
{
    UIImageView *imageView;
}
@end

@implementation ViewController

#pragma mark - UIViewContoller override

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
    

    // Create a view for image display:
    int w = self.view.frame.size.width;
    int h = self.view.frame.size.height;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [imageView setHidden: NO];
    [self.view addSubview:imageView];
    [self.view bringSubviewToFront: imageView];

    [self demo:cv::Size(w, h)];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


-(void) demo:(cv::Size) size
{
    ViewController * __weak weakSelf = self;
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        cv::RNG rng(0xffffffff);
        
        // Draw some stuff for processing:
        cv::Mat colors[3], canvas;
        for(int j = 0; j < 3; j++)
        {
            int i = j;
            cv::RotatedRect ellipse;
            ellipse.angle = rng.uniform(0, 360);
            ellipse.center.x = rng.uniform(size.width/4, size.width*3/4);
            ellipse.center.y = rng.uniform(size.height/4, size.height*3/4);
            ellipse.size.width = rng.uniform(size.width/2, size.width);
            ellipse.size.height = rng.uniform(size.width/2, size.width);
            
            colors[i].create(size.height, size.width, CV_8UC1);
            colors[i] = cv::Scalar::all(0);
            cv::ellipse(colors[i], ellipse, 255, -1, CV_AA);
        }
        
        cv::merge(colors, 3, canvas);
 
        { // http://docs.opencv.org/doc/tutorials/imgproc/shapedescriptors/find_contours/find_contours.html
            
            // Simple opencv functionality test, draw some blobs and find their contours
            cv::Mat gray;
            cv::cvtColor(canvas, gray, cv::COLOR_BGR2GRAY);
            
            cv::Mat output;
            std::vector<std::vector<cv::Point> > contours;
            std::vector<cv::Vec4i> hierarchy;
            
            /// Detect edges using canny
            cv::Canny( gray, output, 32, 64,  3 );

            /// Find contours
            cv::findContours( output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, {0,0} );
            
            /// Draw contours
            for( int i = 0; i< contours.size(); i++ )
            {
                cv::drawContours( canvas, contours, i, {255,255,255}, 2, 8, hierarchy, 0, {} );
            }
        }
        
        UIImage *tmp = [UIImage imageWithCVMat:canvas];
        dispatch_sync(dispatch_get_main_queue(),^{
            ViewController * __strong strongSelf = weakSelf;
            [strongSelf->imageView setImage:tmp];
            NSLog(@"image processed");
        });
    });
}

@end