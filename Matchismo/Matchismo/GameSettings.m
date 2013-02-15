//
//  GameSetting.m
//  Matchismo
//
//  Created by Vasco Orey on 2/15/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "GameSettings.h"

@interface GameSettings()

@property (nonatomic, readwrite) int flipCost;
@property (nonatomic, readwrite) int matchBonus;
@property (nonatomic, readwrite) int mismatchPenalty;

@end

@implementation GameSettings

-(id)initWithFlipCost:(int)flipCost matchBonus:(int)matchBonus andMismatchPenalty:(int)mismatchPenalty
{
    if((self = [super init]))
    {
        _flipCost = flipCost;
        _matchBonus = matchBonus;
        _mismatchPenalty = mismatchPenalty;
    }
    return self;
}

-(id)init
{
    NSAssert(false, @"Use the designated initializer: initWithFlipCost:matchBonus:andMismatchPenalty:");
    return nil;
}

@end
