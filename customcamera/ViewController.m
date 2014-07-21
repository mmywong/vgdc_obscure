//
//  ViewController.m
//  customcamera
//
//  Created by Calvin Tham on 7/20/14.
//  Copyright (c) 2014 Calvin Tham. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIView *FrameForCapture;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)takePhoto:(id)sender;

@end

@implementation ViewController
AVCaptureSession *session;
AVCaptureStillImageOutput *stillImageOutput;

-(void)viewWillAppear:(BOOL)animated
{
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if([session canAddInput:deviceInput])
    {
        [session addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.FrameForCapture.frame;
    
    [previewLayer setFrame:frame];
    
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
    [session startRunning];
}
- (IBAction)takePhoto:(id)sender
{
    AVCaptureConnection *videoConnnection = nil;
    
    for(AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for(AVCaptureInputPort *port in [connection inputPorts])
        {
            if([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                videoConnnection = connection;
                break;
            }
        }
        if(videoConnnection)
        {
            break;
        }
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if(imageDataSampleBuffer != NULL){
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            
            //note:
            //(image.size.height-image.size.width)/2
            //is to account for the borders at the top and bottom of the not yet cropped image
            int barSize = (image.size.height-image.size.width)/2;
            image = [self cropImage:image to:CGRectMake(barSize,0, image.size.width, image.size.height) andScaleTo:CGSizeMake(640, 640)];
            self.imageView.image = image;
            
        }
    }];
}

- (UIImage *)cropImage:(UIImage *)image to:(CGRect)cropRect andScaleTo:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef subImage = CGImageCreateWithImageInRect([image CGImage], cropRect);
    NSLog(@"---------");
    NSLog(@"*cropRect.origin.y=%f",cropRect.origin.y);
    NSLog(@"*cropRect.origin.x=%f",cropRect.origin.x);
    
    NSLog(@"*cropRect.size.width=%f",cropRect.size.width);
    NSLog(@"*cropRect.size.height=%f",cropRect.size.height);
    
    NSLog(@"---------");
    
    NSLog(@"*size.width=%f",size.width);
    NSLog(@"*size.height=%f",size.height);
    
    CGRect myRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, 0.0f, -size.height);
    CGContextDrawImage(context, myRect, subImage);
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(subImage);
    
    //ROTATE LEFT 90 DEGREES
    UIImage * LandscapeImage = croppedImage;
    UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: LandscapeImage.CGImage
                                                         scale: 1.0
                                                   orientation: UIImageOrientationRight];
    
    return PortraitImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
