#import "DrawScene.h"

//4 functions you should look at:
//drawBg - draw a background over the detected rectangle
//makeDuck - makes a duck
//update - called 1000 times a second to update detected rectangle coordinates and draw background
//touchesBegan - touch screen to make a duck (makeDuck)

//declare variables here!
@implementation DrawScene
{
    //the 4 corner points of the rectangle detected
    CGPoint topLeft;
    CGPoint topRight;
    CGPoint bottomRight;
    CGPoint bottomLeft;

    //the SKShapeNode which will overlay the rectangle
    SKShapeNode *fourSidedFigure;
    Sound* soundPlayer;
}

//this function is the update loop
//it is called nonstop 1000 times a second
//used for when you need something to be
//constantly updated
//like updating the detected rectangle's coordinates
//or drawing the background over the detected rectangle
int seconds = 0;
-(void)update:(NSTimeInterval)currentTime
{
    seconds++;
    if(seconds%30==0)
    {
        //update the detected rectangle's 4 points
        [self requestRectangleObjectCoordinates];
        //draw the background
        [self drawBg];
        
        //print the rectangle coordinates
        NSLog(@"Detected Rectangle's 4 pts (x,y):");
        NSLog(@"TopLeft: (%i, %i)\n",(int)topLeft.x,(int)topLeft.y);
        NSLog(@"TopRight: (%i, %i)\n",(int)topRight.x,(int)topRight.y);
        NSLog(@"BottomRight: (%i, %i)\n",(int)bottomRight.x,(int)bottomLeft.y);
        NSLog(@"BottomLeft: (%i, %i)\n",(int)bottomLeft.x,(int)bottomLeft.y);
        NSLog(@"\n");
    }
}

//touched the screen
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *allTouches = [[event allTouches] allObjects];
    [self touchesBeganSettingButtons :allTouches];
    
    //make the SKSpritenode duck spawn when touch the screen
    [self makeDuckFlyUpRight];
    [self makeDuckFlyUpLeft];
    [self makeDuckFlyHorizontallyRight];
    [self makeYourOwnDuckMotion];
}

//DRAW THE BACKGROUND OVER THE DETECTED RECTANGLE
//THE RECTANGLE HAS 4 CGPoints
//to get the x or y:
//topLeft.x or topLeft.y
//4 pts
    //   topLeft ....... topRight
    //           .......
    //           .......
    //bottomLeft         bottomRight
-(void)drawBg
{
    //needed to make the SKShapeNode
    CGPoint rect[] = {topLeft,topRight,bottomRight,bottomLeft,topLeft};
    size_t numPoints = 5;
    
    //if SKShapeNode exists already, delete it
    if(fourSidedFigure!=nil)
        [fourSidedFigure removeFromParent];
    
    //make SKShapeNode at the rectangle’s points and number of points (5)
    fourSidedFigure = [SKShapeNode shapeNodeWithPoints:rect count:numPoints];
    //make the rect green
    [fourSidedFigure setFillColor:[UIColor greenColor]];
    //give it an image for the background
    SKTexture *tex = [SKTexture textureWithImageNamed:@"duck_hunt_bg.png"];
    //apply the image background to it
    [fourSidedFigure setFillTexture:tex];
    //put it behind the ducks
    [fourSidedFigure setZPosition:-1];
    //add it to the screen
    [self addChild:fourSidedFigure];
}

//Make a duck, give it a spritesheet, give it animation, give it sound
-(void)makeDuckFlyUpRight
{
    //make SKSpriteNode!
    CGPoint center = CGPointMake((topLeft.x+topRight.x)/2, (topLeft.y + bottomLeft.y)/2);
    SKSpriteNode *duck = [SKSpriteNode spriteNodeWithImageNamed:@"duck"];
    [duck setPosition:center];
    [self addChild:duck];
    
    //spritesheet!
    //an atlas is a folder in the project
    //here it is called duck.atlas
    //it contains images for the animation spritesheets
    //you use the images to make SKTexture
    //then you make an SKAction called animateWithTextures
    //and run it to apply the spritesheet
    SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:@"duck"];
    SKTexture * duckTex1 = [atlas textureNamed:@"flyUpRight1"];
    SKTexture * duckTex2 = [atlas textureNamed:@"flyUpRight2"];
    NSArray * runTexture = @[duckTex1,duckTex2];
    SKAction* runAnimation = [SKAction animateWithTextures:runTexture timePerFrame:0.075 resize:NO restore:NO];
    [duck runAction:[SKAction repeatActionForever:runAnimation]];
    
    //animations! SKAction!
    //make duck gradually get larger by 500 and 500 in 2 sec
    SKAction* resizeOut = [SKAction resizeByWidth:500 height:500 duration:2];
    //move the duck right by 700px and right by 700px in 2 sec
    SKAction* flyOut = [SKAction moveByX:700 y:700 duration:2];
    //run the actions
    [duck runAction:resizeOut];
    [duck runAction:flyOut];
    
    //sound!
    soundPlayer = [[Sound alloc] init];
    [soundPlayer playSound:@"quack"];}

-(void)makeDuckFlyUpLeft
{
    
}

-(void)makeDuckFlyHorizontallyRight
{
    
}

-(void)makeYourOwnDuckMotion
{
    
}



































//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here
//don't worry about the code after here

//Request rectangle object coordinates
-(void)requestRectangleObjectCoordinates
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"requestRectangleObjectCoordinates"
     object:self];
}
//Receive rectangle object coordinates
-(void)receiveRectangleObjectCoordinates:(NSNotification*)notification{
    NSArray* points = (NSArray*) notification.object;
    
    //update rectangle object coordinates
    NSValue *val;
    val = [points objectAtIndex:0];
    topLeft = [val CGPointValue];
    val = [points objectAtIndex:1];
    topRight = [val CGPointValue];
    val = [points objectAtIndex:2];
    bottomRight = [val CGPointValue];
    val = [points objectAtIndex:3];
    bottomLeft = [val CGPointValue];
}

//draw lines to show the rectangle
//[self drawLinesOnTheRectangleObject];
-(void)drawLinesOnTheRectangleObject
{
    [self beginNewLine:topLeft];
    [self addPointToLine:topRight];
    [self addPointToLine:bottomRight];
    [self addPointToLine:bottomLeft];
    [self addPointToLine:topLeft];
}
//end of detecting rectangle code

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        screenWidth = screenRect.size.width;
        screenHeight = screenRect.size.height;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishedTakingAllScreenshots)
                                                     name:@"finishedTakingAllScreenshots"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveIfCameraSideIsBackAndUpdateIcon:)
                                                     name:@"receiveIfCameraSideIsBackAndUpdateIcon"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveRectangleObjectCoordinates:)
                                                     name:@"sendRectangleObjectCGPoints"
                                                   object:nil];
        
        [self setVariables];
    }
    return self;
}

-(void)setVariables{
    sound = [[Sound alloc] init];
    soundSfx = [[Sound alloc] init];
    
    if((int)(arc4random()%2)==1)
        [sound playSoundForever:@"duck_hunt"];
    else
        [sound playSoundForever:@"duck_hunt_2"];
        
    buttonClear = [SKSpriteNode spriteNodeWithImageNamed:@"button_clear_2"];
    [buttonClear setSize:CGSizeMake(100, 100)];
    [buttonClear setPosition:CGPointMake(buttonClear.size.width/2, buttonClear.size.height/2)];
    [buttonClear setZPosition:100];
    [buttonClear setName:@"button_clear"];
    [buttonClear setAlpha:clearBtnFadeAlpha];
    [self addChild:buttonClear];
    
    buttonClearPressed = [SKSpriteNode spriteNodeWithImageNamed:@"button_clear_pressed_2"];
    [buttonClearPressed setSize: buttonClear.size];
    [buttonClearPressed setScale:1.25];
    [buttonClearPressed setPosition:CGPointMake(buttonClearPressed.size.width/2, buttonClearPressed.size.height/2)];
    [buttonClearPressed setZPosition:99];
    [buttonClearPressed setName:@"button_clear_pressed"];
    [buttonClearPressed setHidden:YES];
    [buttonClearPressed setAlpha:clearBtnFadeAlpha];
    [self addChild:buttonClearPressed];
    
    buttonTakeScreenshot = [SKSpriteNode spriteNodeWithImageNamed:@"button_take_screenshot_blue"];
    [buttonTakeScreenshot setSize:CGSizeMake(50, 50)];
    [buttonTakeScreenshot setPosition:CGPointMake(screenWidth-buttonTakeScreenshot.size.width/2, buttonTakeScreenshot.size.height/2)];
    [buttonTakeScreenshot setZPosition:100];
    [buttonTakeScreenshot setName:@"button_take_screenshot"];
    [buttonTakeScreenshot setAlpha:takeScreenshotBtnFadeAlpha];
    [self addChild:buttonTakeScreenshot];
    
    buttonTakeScreenshotPressed = [SKSpriteNode spriteNodeWithImageNamed:@"button_take_screenshot_pressed_blue"];
    [buttonTakeScreenshotPressed setSize:buttonTakeScreenshot.size];
    [buttonTakeScreenshotPressed setScale:1.25];
    [buttonTakeScreenshotPressed setPosition:CGPointMake(screenWidth-buttonTakeScreenshotPressed.size.width/2, buttonTakeScreenshotPressed.size.height/2)];
    [buttonTakeScreenshotPressed setZPosition:99];
    [buttonTakeScreenshotPressed setName:@"button_take_screenshot_pressed"];
    [buttonTakeScreenshotPressed setHidden:YES];
    [buttonTakeScreenshotPressed setAlpha:takeScreenshotBtnFadeAlpha];
    [self addChild:buttonTakeScreenshotPressed];
    
    stillTakingScreenshot = NO;
    
    [self sendGetIfCameraSideIsBack];
}

-(void)switchCamera{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"switch_camera"
     object:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSArray *allTouches = [[event allTouches] allObjects];
    
    if([allTouches count] > 1)
        return;
    else{
        UITouch *touch = [allTouches objectAtIndex:0];
        CGPoint loc = [touch locationInNode:self];
        
        //set alpha 1 buttons if not drawing onto them
        if(!stillTakingScreenshot){
            if(buttonClear.alpha < btnFadeAlpha){
                [buttonClear setAlpha:btnFadeAlpha];
            }
            if(buttonSwitchCamera.alpha < btnFadeAlpha){
                [buttonSwitchCamera setAlpha:btnFadeAlpha];
            }
            if(buttonTakeScreenshot.alpha < btnFadeAlpha){
                [buttonTakeScreenshot setAlpha:btnFadeAlpha];
            }
        }
        
        //hide all buttons when drawing
        if(!buttonClear.isHidden && !buttonTakeScreenshot.isHidden && !buttonSwitchCamera.isHidden)
            [self hideButtons];
        
        //hide buttons if drawing over them
        if(buttonClearPressed.isHidden && buttonClear.isHidden){
            if([self nodeAtPoint:loc].name != nil){
                if([[self nodeAtPoint:loc].name isEqualToString:buttonClear.name])
                    [buttonClear setAlpha:btnMaxFadeAlpha];
                if([[self nodeAtPoint:loc].name isEqualToString:buttonSwitchCamera.name]){
                    [buttonSwitchCamera setAlpha:btnMaxFadeAlpha];
                }
                if([[self nodeAtPoint:loc].name isEqualToString:buttonTakeScreenshot.name])
                    [buttonTakeScreenshot setAlpha:btnMaxFadeAlpha];
            }
        }
    }
}

-(void)sendGetIfCameraSideIsBack{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getIfCameraSideIsBack"
     object:nil];
}

-(void)receiveIfCameraSideIsBackAndUpdateIcon :(NSNotification *)notification {
    
    //remove buttonSwitchCamera and buttonSwitchCameraPressed nodes if they exist
    if(buttonSwitchCamera != nil)
        [buttonSwitchCamera removeFromParent];
    if(buttonSwitchCameraPressed != nil)
        [buttonSwitchCameraPressed removeFromParent];
    
    NSString* cameraType = (NSString*)notification.object;
    //NSLog(@"%@",cameraType);
    //NSLog(@"RECEIVED");
    if([cameraType isEqualToString:@"BACK"]){
        buttonSwitchCamera = [SKSpriteNode spriteNodeWithImageNamed:@"button_switch_camera_pressed_2"];
        [buttonSwitchCamera setSize:buttonTakeScreenshot.size];
        
        buttonSwitchCameraPressed = [SKSpriteNode spriteNodeWithImageNamed:@"button_switch_camera_pressed_2"];
    }
    else{
        buttonSwitchCamera = [SKSpriteNode spriteNodeWithImageNamed:@"button_switch_camera_2"];
        
        buttonSwitchCameraPressed = [SKSpriteNode spriteNodeWithImageNamed:@"button_switch_camera_2"];
    }
    
    [buttonSwitchCamera setSize:buttonTakeScreenshot.size];
    [buttonSwitchCamera setPosition:CGPointMake(screenWidth-buttonSwitchCamera.size.width/2,screenHeight-buttonSwitchCamera.size.height/2)];
    [buttonSwitchCamera setZPosition:100];
    [buttonSwitchCamera setName:@"button_switch_camera"];
    [buttonSwitchCamera setAlpha:switchCameraBtnFadeAlpha];
    
    [buttonSwitchCameraPressed setZPosition:99];
    [buttonSwitchCameraPressed setName:@"button_switch_camera_pressed"];
    [buttonSwitchCameraPressed setHidden:YES];
    [buttonSwitchCameraPressed setAlpha:switchCameraBtnFadeAlpha];
    [buttonSwitchCameraPressed setSize:buttonSwitchCamera.size];
    [buttonSwitchCameraPressed setScale:1.25];
    [buttonSwitchCameraPressed setPosition:CGPointMake(screenWidth-buttonSwitchCameraPressed.size.width/2,screenHeight-buttonSwitchCameraPressed.size.height/2)];
    [self addChild:buttonSwitchCamera];
    [self addChild:buttonSwitchCameraPressed];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSArray *allTouches = [[event allTouches] allObjects];
    
    UITouch *touch = [allTouches objectAtIndex:0];
    CGPoint loc = [touch locationInNode:self];
    
    if([[self nodeAtPoint:loc].name isEqualToString:buttonClear.name] && !buttonClearPressed.isHidden){
        [self removeAllChildren];
        [self setVariables];
    }
    else if([[self nodeAtPoint:loc].name isEqualToString:buttonSwitchCamera.name] && !buttonSwitchCameraPressed.isHidden){
        if([self checkAccessCameraPermission] == YES)
            [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(switchCamera) userInfo:nil repeats:NO];
        
    }
    else if([[self nodeAtPoint:loc].name isEqualToString:buttonTakeScreenshot.name] && !buttonTakeScreenshotPressed.isHidden){
        
        if([self checkAccessPhotoLibraryPermission] == YES){
            [buttonTakeScreenshot setHidden:NO];
            [buttonTakeScreenshotPressed setHidden:YES];
            
            if(!stillTakingScreenshot){
                stillTakingScreenshot = YES;
                [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(hideThenSaveScreenshotToPhotos) userInfo:nil repeats:NO];
            }
        }
    }
    
    //set alpha 1 buttons if not drawing onto them
    if(!stillTakingScreenshot){
        if(buttonClear.alpha < btnFadeAlpha){
            [buttonClear setAlpha:btnFadeAlpha];
        }
        if(buttonSwitchCamera.alpha < btnFadeAlpha){
            [buttonSwitchCamera setAlpha:btnFadeAlpha];
        }
        if(buttonTakeScreenshot.alpha < btnFadeAlpha){
            [buttonTakeScreenshot setAlpha:btnFadeAlpha];
        }
    }
    
    //unhide btns if hidden
    if(!stillTakingScreenshot){
        if(buttonClear.isHidden){
            [buttonClear setHidden:NO];
            [buttonClearPressed setHidden:YES];
        }
        if(buttonSwitchCamera.isHidden && buttonSwitchCameraPressed.isHidden && ![[self nodeAtPoint:loc].name isEqualToString: buttonSwitchCameraPressed.name]){
            [buttonSwitchCamera setHidden:NO];
            [buttonSwitchCameraPressed setHidden:YES];
        }
        else if(buttonSwitchCamera.isHidden && ![[self nodeAtPoint:loc].name isEqualToString: buttonSwitchCamera.name]){
            [buttonSwitchCamera setHidden:NO];
            [buttonSwitchCameraPressed setHidden:YES];
        }
        if(buttonTakeScreenshot.isHidden){
            [buttonTakeScreenshot setHidden:NO];
            [buttonTakeScreenshotPressed setHidden:YES];
        }
    }
    
    if([allTouches count] > 1)
        return;
    else if([self nodeAtPoint:loc].name == nil && buttonClearPressed.isHidden && buttonSwitchCameraPressed.isHidden && buttonClear.isHidden){
        
    }
    
}

-(Boolean)checkAccessCameraPermission{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(status !=  AVAuthorizationStatusNotDetermined)
        if (status == ALAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Cannot show camera's video feed until Pawrikura gets access permission to Camera in your Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    
    return YES;
}

-(Boolean)checkAccessDoodleCameraPermission{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(status !=  AVAuthorizationStatusNotDetermined)
        if (status == ALAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Only saved screenshot of doodle. Please give permission to access Camera in your Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    
    return YES;
}

-(Boolean)checkAccessPhotoLibraryPermission{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if(status !=  ALAuthorizationStatusNotDetermined)
        if (status == ALAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Cannot take screenshot until you give Pawrikura access permission to Photo Library in your Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    
    return YES;
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *allTouches = [[event allTouches] allObjects];
    
    if([allTouches count] > 1)
        return;
    
    UITouch *touch = [allTouches objectAtIndex:0];
    CGPoint loc = [touch locationInNode:self];
    
}

-(void)beginNewLine:(CGPoint)startPt{
    SKShapeNode *line = [SKShapeNode node];
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, startPt.x, startPt.y);
    line.path = pathToDraw;
    
    UIColor *orangish = [UIColor colorWithRed:255/255.0 green:222/255.0 blue:0/255.0 alpha:1];
    
    //random color generator
    //UIColor *orangish = [UIColor colorWithRed:(arc4random() %256)/255.0 green:(arc4random() %256)/255.0 blue:(arc4random() %256)/255.0 alpha:1];
    [line setStrokeColor:orangish];
    [line setFillColor:orangish];
    [line setGlowWidth:10.0];
    [line setLineWidth:6.0];
    [line setLineCap:kCGLineCapButt];
    [line setLineJoin:kCGLineJoinRound];
    currentLine = line;
    currentPathToDraw = pathToDraw;
    [self addChild:line];
}

-(void)addPointToLine:(CGPoint)pt{
    CGPathAddLineToPoint(currentPathToDraw, NULL, pt.x, pt.y);
    CGPathMoveToPoint(currentPathToDraw, NULL, pt.x, pt.y);
    //Cool background pattern effect!
    //[currentLine setLineWidth:6+(arc4random() %0)];
    currentLine.path = currentPathToDraw;
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

-(void)finishedTakingAllScreenshots{
    [self showButtons];
    stillTakingScreenshot = NO;
}

-(void)hideButtons{
    [buttonClear setHidden:YES];
    [buttonClearPressed setHidden:YES];
    [buttonTakeScreenshot setHidden:YES];
    [buttonTakeScreenshotPressed setHidden:YES];
    [buttonSwitchCamera setHidden:YES];
    [buttonSwitchCameraPressed setHidden:YES];
}

-(void)showButtons{
    [buttonClear setHidden:NO];
    [buttonSwitchCamera setHidden:NO];
    [buttonTakeScreenshot setHidden:NO];
}

-(void)touchesBeganSettingButtons :(NSArray*)allTouches
{
    if([allTouches count] > 1)
    {
        return;
    }
    else{
        UITouch *touch = [allTouches objectAtIndex:0];
        CGPoint loc = [touch locationInNode:self];
        
        if([[self nodeAtPoint:loc].name isEqualToString:buttonClear.name]){
            [buttonClear setHidden:YES];
            [buttonClearPressed setHidden:NO];
        }
        else if([[self nodeAtPoint:loc].name isEqualToString:buttonSwitchCamera.name]){
            [buttonSwitchCamera setHidden:YES];
            [buttonSwitchCameraPressed setHidden:NO];
        }
        else if([[self nodeAtPoint:loc].name isEqualToString:buttonTakeScreenshot.name]){
            [buttonTakeScreenshot setHidden:YES];
            [buttonTakeScreenshotPressed setHidden:NO];
        }
    }
}

@end
