//
//  Sound.m
//  AutismMinigames
//
//  Created by Calvin Tham on 4/19/14.
//  Copyright (c) 2014 Calvin Tham. All rights reserved.
//

#import "Sound.h"

@implementation Sound
-(void) playSound:(NSString*)fileName
{
    NSString *formattedString = [NSString stringWithFormat:@"%@/%@.aiff", [[NSBundle mainBundle] resourcePath], fileName];
    NSURL *url = [NSURL fileURLWithPath:formattedString];
    bg = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [bg setEnableRate:YES];
    [bg setRate:1];
    [bg setVolume:0.7];
    [bg play];
}
-(void) playSound:(NSString*)fileName :(float)volume
{
    NSString *formattedString = [NSString stringWithFormat:@"%@/%@.aiff", [[NSBundle mainBundle] resourcePath], fileName];
    NSURL *url = [NSURL fileURLWithPath:formattedString];
    bg = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [bg setEnableRate:YES];
    [bg setRate:1];
    [bg setVolume:volume];
    [bg play];
}
-(void) playSoundForever:(NSString*)fileName
{
    NSString *formattedString = [NSString stringWithFormat:@"%@/%@.aiff", [[NSBundle mainBundle] resourcePath], fileName];
    NSURL *url = [NSURL fileURLWithPath:formattedString];
    bg = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [bg setEnableRate:YES];
    [bg setRate:1];
    [bg setVolume:0.7];
    [bg play];
    [bg setNumberOfLoops:99];
}

-(void) stopSound
{
    [bg stop];
}

-(float) getDuration
{
    return (float)bg.duration;
}
@end
