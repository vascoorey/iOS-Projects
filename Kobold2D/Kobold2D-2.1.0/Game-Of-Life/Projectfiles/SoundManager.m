//
//  SoundManager.m
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/12/13.
//
//

#import "SoundManager.h"
#import "SimpleAudioEngine.h"

#define SOUNDS @[@"C3.aif", @"D3.aif", @"E3.aif", @"F3.aif", @"G3.aif", @"A3.aif", @"B3.aif"]

@interface SoundManager ()
@property (nonatomic, strong) NSMutableDictionary *notesToPlay;
@end

@implementation SoundManager

-(NSMutableDictionary *)notesToPlay
{
    if(!_notesToPlay)
    {
        _notesToPlay = [[NSMutableDictionary alloc] init];
    }
    return _notesToPlay;
}

-(void)pushNoteAtRow:(NSInteger)row col:(NSInteger)col
{
    if([self.notesToPlay.allKeys containsObject:@(row)])
    {
        self.notesToPlay[@(row)] = @([self.notesToPlay[@(row)] intValue] + 1);
    }
    else
    {
        self.notesToPlay[@(row)] = @(1);
    }
}

-(void)play
{
    
}

@end
