//
//  GameSetting.m
//  Matchismo
//
//  Created by Vasco Orey on 2/15/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "GameSettings.h"

@interface GameSettings()
@end

@implementation GameSettings

-(id)initWithFlipCost:(NSUInteger)flipCost matchBonus:(NSUInteger)matchBonus mismatchPenalty:(NSUInteger)mismatchPenalty matchMode:(NSUInteger)matchMode shouldRedealCards:(BOOL)shouldRedealCards startingCardCount:(NSUInteger)startingCardCount
{
    if((self = [super init]))
    {
        _flipCost = flipCost;
        _matchBonus = matchBonus;
        _mismatchPenalty = mismatchPenalty;
        _matchMode = matchMode;
        _shouldRedealCards = shouldRedealCards;
        _startingCardCount = startingCardCount;
    }
    return self;
}

-(id)init
{
    NSAssert(false, @"Use the designated initializer: initWithFlipCost:matchBonus:andMismatchPenalty:");
    return nil;
}

@end
