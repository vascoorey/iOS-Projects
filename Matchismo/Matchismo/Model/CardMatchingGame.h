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
@property (nonatomic, readonly) NSInteger cardsInPlay;
@property (nonatomic, readonly) BOOL hasUnplayableCards;
@property (nonatomic, readonly) NSMutableArray *cards;

// Designated Initializer
-(id)initWithDeck:(Deck *)deck
             name:(NSString *)name;
-(void)flipCardAtIndex:(NSUInteger)index;
-(Card *)cardAtIndex:(NSUInteger)index;
-(NSString *)descriptionOfFlip:(NSInteger)flip;
-(NSArray *)cardsForLastFlip;
-(NSArray *)indicesForMatch;

// Both return NSArray of NSIndexPath for the cards added/removed
-(NSArray *)requestCards:(NSUInteger)cards;
-(NSArray *)removeUnplayableCards;

@end
