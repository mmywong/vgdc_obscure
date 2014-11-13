//
//  Sound.h
//  AutismMinigames
//
//  Created by Calvin Tham on 4/19/14.
//  Copyright (c) 2014 Calvin Tham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface Sound : NSObject
{
    AVAudioPlayer *bg;
}
-(void)playSound:(NSString*)fileName;
-(void)playSound:(NSString*)fileName :(float)volume;
-(void)playSoundForever:(NSString*)fileName;
-(void)stopSound;
-(float)getDuration;
@end
