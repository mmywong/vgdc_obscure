//
//  ViewController.m
//  customcamera
//
//  Created by Calvin Tham on 7/20/14.
//  Copyright (c) 2014 Calvin Tham. All rights reserved.
//

//remove NSLogs from release build

#import "ViewController.h"
#import <CoreFoundation/CoreFoundation.h>
#import  <ImageIO/CGImageProperties.h>
@implementation ViewController
AVCaptureSession *session;
AVCaptureStillImageOutput *stillImageOutput;
AVCaptureDevice *inputDevice;
AVCaptureDeviceInput *deviceInput;
AVCaptureVideoPreviewLayer *previewLayer;
NSDictionary *outputSettings;

- (void)loadView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchCameraTapped:)
                                                 name:@"switch_camera"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveScreenshotToPhotos:)
                                                 name:@"save_screenshot"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneTakingScreenshotOfCamera:)
                                                 name:@"doneTakingScreenshotOfCamera"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getIfCameraSideIsBack)
                                                 name:@"getIfCameraSideIsBack"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedUpdatingLiveCameraFeedImage:)
                                                 name:@"finishedUpdatingLiveCameraFeedImage"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRequestForRectangleObjectCGPoints)
                                                 name:@"requestRectangleObjectCoordinates"
                                               object:nil];
    
    parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [self setView:parentView];
    
    cameraView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [self startCamera];
    
    cameraSideIsBack = YES;
    imageView = [[UIImageView alloc] init];
    finalImage = [[UIImage alloc] init];
    
    [parentView addSubview:cameraView];
    
    SKView * skView = [[SKView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    SKScene *clothesScene = [DrawScene sceneWithSize:skView.bounds.size];
    clothesScene.scaleMode = SKSceneScaleModeAspectFill;
    
    skView.allowsTransparency = YES;
    clothesScene.backgroundColor = [UIColor clearColor];
    [parentView addSubview:skView];
    [skView presentScene:clothesScene];
    
    //update the live camera feed UIImage and then detect for rectangles
    //then update the rectangle's 4 CGPoints
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(updateLiveCameraFeedImageAndDetectForRectangles)
                                   userInfo:nil
                                    repeats:YES];
}



-(void)viewWillAppear:(BOOL)animated{
    //call deallocSession when exit app to background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deallocSession) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deallocSession) name:UIApplicationWillChangeStatusBarFrameNotification object:[UIApplication sharedApplication]];
    //call startCamera when return to app from background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCamera) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCamera) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)deallocSession
{
    NSLog(@"DISAPPEAR");
    [previewLayer removeFromSuperlayer];
    for(AVCaptureInput *input1 in session.inputs) {
        [session removeInput:input1];
    }
    
    for(AVCaptureOutput *output1 in session.outputs) {
        [session removeOutput:output1];
    }
    
    [session stopRunning];
    session=nil;
    outputSettings=nil;
    inputDevice=nil;
    deviceInput=nil;
    previewLayer=nil;
    stillImageOutput=nil;
}
-(void)startCamera
{
    NSLog(@"APPEARED");
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error;
    
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if([session canAddInput:deviceInput])
    {
        [session addInput:deviceInput];
    }
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [cameraView layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = CGRectMake(0,0, screenWidth, screenHeight);
    
    //[previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    
    [previewLayer setFrame:frame];
    
    [rootLayer insertSublayer:previewLayer above:rootLayer];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    
    [session addOutput:stillImageOutput];
    
    [session startRunning];
    
    if(cameraSideIsBack == NO)
        [self switchCameraTapped:self];
    
}

-(void)getIfCameraSideIsBack{
    //NSLog(@"SENT");
    NSString *cameraType;
    
    if(cameraSideIsBack){
        cameraType = @"BACK";
    }
    else
        cameraType = @"FRONT";
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"receiveIfCameraSideIsBackAndUpdateIcon"
     object:cameraType];
}

-(IBAction)switchCameraTapped:(id)sender
{
    //Change camera source
    if(session){
        
        //NSLog(@"SWITCHING CAMERA");
        //Indicate that some changes will be made to the session
        [session beginConfiguration];
        
        //Remove existing input
        [session removeInput:deviceInput];
        
        //Get new input
        inputDevice = nil;
        if(deviceInput.device.position == AVCaptureDevicePositionBack)
        {
            inputDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
            cameraSideIsBack = NO;
        }
        else
        {
            inputDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
            cameraSideIsBack = YES;
        }
        
        //Add input to session
        deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputDevice error:nil];
        [session addInput:deviceInput];
        
        //Commit all the configuration changes at once
        [session commitConfiguration];
    }
    
    //change icon to reflect switched camera (either front or back)
    [self getIfCameraSideIsBack];
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
    //return nil;
}

-(void)saveScreenshotToPhotos:(NSNotification*)notification{
    drawingScreenshot = (UIImage*) notification.object;
    [self takePhoto:nil];
}



- (void)takePhoto:(id)sender
{
    //[self updateLiveCameraFeedImage];
    //[self detectForFacesInUIImage:liveCameraFeedImage];
    
    __block UIImage* savedImage;
    AVCaptureConnection *videoConnnection = nil;
    
    for(AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for(AVCaptureInputPort *port in [connection inputPorts])
        {
            if([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                //NSLog(@"YAY");
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
        CFDictionaryRef exifAttachments = CMGetAttachment( imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments)
        {
            // Do something with the attachments.
            //NSLog(@"attachements: %@", exifAttachments);
        }
        else
        {
            //NSLog(@"no attachments");
        }
        if(imageDataSampleBuffer != NULL){
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            
            [imageView setBounds:previewLayer.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.transform = CGAffineTransformMake(
                                                        1, 0, 0, -1, 0, imageView.bounds.size.width
                                                        );
            [imageView setImage:image];
            
            UIGraphicsBeginImageContext(imageView.frame.size);
            [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            savedImage = image;
            finalImage = savedImage;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"doneTakingScreenshotOfCamera"
             object:savedImage];
        }
    }];
}

-(void)doneTakingScreenshotOfCamera:(NSNotification*)notification{
    cameraScreenshot = (UIImage*) notification.object;
    
    UIImage *imageFromCamera = cameraScreenshot;
    UIImage *image_front = drawingScreenshot;
    
    //UIImageWriteToSavedPhotosAlbum(image_front, nil,nil,nil);
    
    //flip camera image if facing user, because that is mirrored
    if(deviceInput.device.position == AVCaptureDevicePositionFront)
        imageFromCamera = [UIImage imageWithCGImage:imageFromCamera.CGImage
                                              scale:imageFromCamera.scale
                                        orientation:UIImageOrientationUpMirrored];
    
    UIImage *image_together = [self imageByCombiningImage:imageFromCamera withImage:image_front];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"finishedTakingAllScreenshots"
     object:nil];
}

-(UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize newImageSize = CGSizeMake(MAX(firstImage.size.width, secondImage.size.width), MAX(firstImage.size.height, secondImage.size.height));
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(newImageSize);
    }
    [firstImage drawAtPoint:CGPointMake(roundf((newImageSize.width-firstImage.size.width)/2),
                                        roundf((newImageSize.height-firstImage.size.height)/2))];
    [secondImage drawAtPoint:CGPointMake(roundf((newImageSize.width-secondImage.size.width)/2),
                                         roundf((newImageSize.height-secondImage.size.height)/2))];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}


//RECTANGLE OBJECT DETECTION
-(void)detectForFacesInUIImage:(UIImage *)facePicture
{
    CIImage* image = [CIImage imageWithCGImage:facePicture.CGImage];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeRectangle
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    NSArray* features = [detector featuresInImage:image];
    for(CIRectangleFeature* faceObject in features)
    {
        topLeft = faceObject.topLeft;
        topRight = faceObject.topRight;
        bottomRight = faceObject.bottomRight;
        bottomLeft = faceObject.bottomLeft;
    }
}

-(void)updateLiveCameraFeedImageAndDetectForRectangles
{
    [self updateLiveCameraFeedImage];
    [self detectForFacesInUIImage:liveCameraFeedImage];
}
- (void)updateLiveCameraFeedImage
{
    __block UIImage* savedImage;
    AVCaptureConnection *videoConnnection = nil;
    
    for(AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for(AVCaptureInputPort *port in [connection inputPorts])
        {
            if([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                //NSLog(@"YAY");
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
        CFDictionaryRef exifAttachments = CMGetAttachment( imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments)
        {
            // Do something with the attachments.
            //NSLog(@"attachements: %@", exifAttachments);
        }
        else
        {
            //NSLog(@"no attachments");
        }
        if(imageDataSampleBuffer != NULL){
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            
            [imageView setBounds:previewLayer.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.transform = CGAffineTransformMake(
                                                        1, 0, 0, -1, 0, imageView.bounds.size.width
                                                        );
            [imageView setImage:image];
            
            UIGraphicsBeginImageContext(imageView.frame.size);
            [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            savedImage = image;
            finalImage = savedImage;
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"finishedUpdatingLiveCameraFeedImage"
             object:savedImage];
        }
    }];
}

-(void)finishedUpdatingLiveCameraFeedImage:(NSNotification*)notification{
    liveCameraFeedImage = (UIImage*) notification.object;
}

//from DrawScene
-(void)receiveRequestForRectangleObjectCGPoints
{
    NSArray *points = [NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:topLeft],
                       [NSValue valueWithCGPoint:topRight],
                       [NSValue valueWithCGPoint:bottomRight],
                       [NSValue valueWithCGPoint:bottomLeft],
                       nil];
    [self sendRectangleObjectCGPoints:points];
}

-(void)sendRectangleObjectCGPoints:(NSArray*)points
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sendRectangleObjectCGPoints"
     object:points];
}

@end
