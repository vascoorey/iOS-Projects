//
//  GameSetting.h
//  Matchismo
//
//  Created by Vasco Orey on 2/15/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSettings : NSObject

@property (nonatomic, readonly) int flipCost;
@property (nonatomic, readonly) int matchBonus;
@property (nonatomic, readonly) int mismatchPenalty;
@property (nonatomic, readonly) int matchMode;
@property (nonatomic, readonly) BOOL shouldRedealCards;

// Designated Initializer
-(id)initWithFlipCost:(int)flipCost
           matchBonus:(int)matchBonus
      mismatchPenalty:(int)mismatchPenalty
            matchMode:(int)matchMode
    shouldRedealCards:(BOOL)shouldRedealCard;

@end
