//
//  AppDelegate.m
//  customcamera
//
//  Created by Calvin Tham on 7/20/14.
//  Copyright (c) 2014 Calvin Tham. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BlackViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    if(!TARGET_IPHONE_SIMULATOR)
    {
        if([self checkAccessCameraPermission] == YES){
        ViewController *test = [[ViewController alloc]     initWithNibName:@"ViewController" bundle:nil];
        self.window.rootViewController = test;
        }
    }
    else{
        //EMPTY VIEW CONTROLLER FOR WHEN NO ACCESS TO CAMERA + SKVIEW
        BlackViewController *test = [[BlackViewController alloc] init];
        self.window.rootViewController = test;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        int screenWidth = screenRect.size.width;
        int screenHeight = screenRect.size.height;
        SKView * skView = [[SKView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        SKScene *clothesScene = [DrawScene sceneWithSize:skView.bounds.size];
        clothesScene.scaleMode = SKSceneScaleModeAspectFill;
        
        [test setView:skView];
        skView.allowsTransparency = NO; //change to YES later
        clothesScene.backgroundColor = [UIColor clearColor];
        [skView presentScene:clothesScene];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(Boolean)checkAccessCameraPermission{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(status !=  AVAuthorizationStatusNotDetermined)
        if (status == ALAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Cannot show camera's video feed until BasicCustomCamera gets access permission to Camera in your Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
