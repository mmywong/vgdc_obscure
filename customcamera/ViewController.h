//
//  ViewController.h
//  customcamera
//
//  Created by Calvin Tham on 7/20/14.
//  Copyright (c) 2014 Calvin Tham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "DrawScene.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController
{
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    UIView *parentView;
    UIView *cameraView;
    
    SKView * skView;
    __block UIImage *finalImage;
    UIImageView *imageView;
    UIImage *cameraScreenshot;
    UIImage *drawingScreenshot;
    
    Boolean cameraSideIsBack;
    
    //liveCameraFeedImage is an image of the camera feed that is used to detect rectangles
    UIImage *liveCameraFeedImage;
    //the points of the rectangle detected
    CGPoint topLeft;
    CGPoint topRight;
    CGPoint bottomRight;
    CGPoint bottomLeft;
}
- (void)takePhoto:(id)sender;

@end
