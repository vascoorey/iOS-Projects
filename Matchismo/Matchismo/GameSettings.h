//
//  GameSetting.h
//  Matchismo
//
//  Created by Vasco Orey on 2/15/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSettings : NSObject

@property (nonatomic) NSUInteger flipCost;
@property (nonatomic) NSUInteger matchBonus;
@property (nonatomic) NSUInteger mismatchPenalty;
@property (nonatomic) NSUInteger matchMode;
@property (nonatomic) NSUInteger startingCardCount;
@property (nonatomic) BOOL penalizeCheating;

// Designated Initializer
-(id)initWithFlipCost:(NSUInteger)flipCost
           matchBonus:(NSUInteger)matchBonus
      mismatchPenalty:(NSUInteger)mismatchPenalty
            matchMode:(NSUInteger)matchMode
     startingCardCount:(NSUInteger)startingCardCount;

@end
