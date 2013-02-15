//
//  CardMatchingGame.h
//  Matchismo
//
//  Created by Vasco Orey on 2/1/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Deck.h"
#import "GameSettings.h"

@interface CardMatchingGame : NSObject

@property (nonatomic, readonly) NSInteger score;
@property (nonatomic, readonly) NSString *descriptionOfLastFlip;
@property (nonatomic, readonly) NSInteger flipCount;

// Designated Initializer
-(id)initWithCardCount:(NSUInteger)count
             usingDeck:(Deck *)deck
       andGameSettings:(GameSettings *)settings;
-(void)flipCardAtIndex:(NSUInteger)index;
-(Card *)cardAtIndex:(NSUInteger)index;
-(void)switchMatchingMode;
-(NSString *)descriptionOfFlip:(NSInteger)flip;

@end
