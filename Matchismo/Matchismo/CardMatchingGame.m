//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Vasco Orey on 2/1/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame ()
@property (readwrite, nonatomic) NSInteger score;
@property (readwrite, nonatomic) NSString *descriptionOfLastFlip;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) Deck *playingDeck;
@property (nonatomic) NSInteger cardCount;
@property (nonatomic, getter = isDefaultMatchMode) BOOL defaultMatchMode;
@property (nonatomic, strong) NSMutableArray *flipHistory;
@end

@implementation CardMatchingGame

@synthesize flipCount;

-(NSInteger)flipCount
{
    return [self.flipHistory count];
}

-(NSMutableArray *)cards
{
    if(!_cards)
    {
        _cards = [[NSMutableArray alloc] init];
    }
    return _cards;
}

-(NSMutableArray *)flipHistory
{
    if(!_flipHistory)
    {
        _flipHistory = [[NSMutableArray alloc] init];
    }
    return _flipHistory;
}

-(void)switchMatchingMode
{
    self.defaultMatchMode = !self.defaultMatchMode;
}

-(BOOL)reset
{
    for(int i = 0; i < self.cardCount; i++)
    {
        Card *card = [self.playingDeck drawRandomCard];
        if(card)
        {
            self.cards[i] = card;
        }
        else
        {
            return NO;
        }
    }
    self.score = 0;
    self.descriptionOfLastFlip = @"Last flip.";
    [self.flipHistory removeAllObjects];
    return YES;
}

-(id)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck
{
    if((self = [super init]))
    {
        self.playingDeck = deck;
        self.cardCount = count;
        self.defaultMatchMode = YES;
        if(![self reset])
        {
            self = nil;
        }
    }
    return self;
}

-(NSString *)descriptionOfFlip:(NSInteger)flip
{
    NSString *flipDescription = nil;
    if(flip > 0 && flip <= self.flipCount)
    {
        flipDescription = self.flipHistory[flip - 1];
    }
    return flipDescription;
}

-(Card *)cardAtIndex:(NSUInteger)index
{
    return index < [self.cards count] ? self.cards[index] : nil;
}

-(BOOL)canCheckForMatches:(NSMutableArray *)matches
{
    return (self.isDefaultMatchMode && [matches count] == 1) || (!self.isDefaultMatchMode && [matches count] == 2);
}

#define MATCH_BONUS 4
#define MISMATCH_PENALTY 2
#define FLIP_COST 1
-(void)flipCardAtIndex:(NSUInteger)index
{
    Card *card = [self cardAtIndex:index];
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    
    if(card && !card.isUnplayable)
    {
        self.descriptionOfLastFlip = [NSString stringWithFormat:@"Flipped %@", card];
        if(!card.isFaceUp)
        {
            // Check for matches
            for(Card *otherCard in self.cards)
            {
                if(otherCard.isFaceUp && !otherCard.isUnplayable)
                {
                    [matches addObject:otherCard];
                    if(self.isDefaultMatchMode || [matches count] == 2)
                    {
                        break;
                    }
                }
            }
            
            if([self canCheckForMatches:matches])
            {
                // Calculate
                int matchScore = [card match:matches];
                if(matchScore)
                {
                    card.unplayable = YES;
                    self.score += matchScore * MATCH_BONUS * [matches count];
                    self.descriptionOfLastFlip = [NSString stringWithFormat:@"Matched %@", card];
                    for(Card *otherCard in matches)
                    {
                        otherCard.unplayable = YES;
                        self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@", %@", otherCard]];
                    }
                    self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@" for %d points.", matchScore * MATCH_BONUS * [matches count]]];
                }
                else
                {
                    self.score -= MISMATCH_PENALTY;
                    self.descriptionOfLastFlip = [NSString stringWithFormat:@"%@", card];
                    for(Card *otherCard in matches)
                    {
                        self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@", %@", otherCard]];
                        otherCard.faceUp = NO;
                    }
                    self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@" dont match. %d point penalty.", matchScore - MISMATCH_PENALTY]];
                }
            }
            [self.flipHistory addObject:self.descriptionOfLastFlip];
            self.score -= FLIP_COST;
        }
        card.faceUp = !card.isFaceUp;
    }
}

@end
