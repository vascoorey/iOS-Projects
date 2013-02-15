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
@property (nonatomic, readwrite) int matchMode;
@property (nonatomic, readwrite) BOOL shouldRedealCards;

@end

@implementation GameSettings

-(id)initWithFlipCost:(int)flipCost matchBonus:(int)matchBonus mismatchPenalty:(int)mismatchPenalty matchMode:(int)matchMode shouldRedealCards:(BOOL)shouldRedealCards
{
    if((self = [super init]))
    {
        _flipCost = flipCost;
        _matchBonus = matchBonus;
        _mismatchPenalty = mismatchPenalty;
        _matchMode = matchMode;
        _shouldRedealCards = shouldRedealCards;
    }
    return self;
}

-(id)init
{
    NSAssert(false, @"Use the designated initializer: initWithFlipCost:matchBonus:andMismatchPenalty:");
    return nil;
}

@end
