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

@interface CardMatchingGame : NSObject

@property (nonatomic, readonly) NSInteger score;
@property (nonatomic, readonly) NSString *descriptionOfLastFlip;

// Designated Initializer
-(id)initWithCardCount:(NSUInteger)count
             usingDeck:(Deck *)deck;
-(BOOL)reset;
-(void)flipCardAtIndex:(NSUInteger)index;
-(Card *)cardAtIndex:(NSUInteger)index;
-(void)switchMatchingMode;

@end
