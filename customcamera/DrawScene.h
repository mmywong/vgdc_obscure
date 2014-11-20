//
//  DrawScene.h
//  TicTacVideo
//
//  Created by Calvin Tham on 7/28/14.
//  Copyright (c) 2014 Calvin Tham. All rights reserved.
//
#define btnFadeAlpha 0.3
#define clearBtnFadeAlpha 0.3
#define takeScreenshotBtnFadeAlpha 0.3
#define switchCameraBtnFadeAlpha 0.3
#define pawBtnFadeAlpha 0.3
#define btnMaxFadeAlpha 0.05

#import "Sound.h"

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <SceneKit/SceneKit.h>

@interface DrawScene : SKScene
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    SKShapeNode *currentLine;
    CGMutablePathRef currentPathToDraw;
    
    SKSpriteNode *buttonClear;
    SKSpriteNode *buttonClearPressed;
    
    SKSpriteNode *buttonSwitchCamera;
    SKSpriteNode *buttonSwitchCameraPressed;
    
    SKSpriteNode *buttonTakeScreenshot;
    SKSpriteNode *buttonTakeScreenshotPressed;
    
    Boolean stillTakingScreenshot;
    
    Sound *sound;
    Sound *soundSfx;
    NSMutableArray *lines;
}

@end
