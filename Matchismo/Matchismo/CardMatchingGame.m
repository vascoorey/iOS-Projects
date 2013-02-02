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
@end

@implementation CardMatchingGame

-(NSMutableArray *)cards
{
    if(!_cards)
    {
        _cards = [[NSMutableArray alloc] init];
    }
    return _cards;
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
    return YES;
}

-(id)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck
{
    if((self = [super init]))
    {
        self.playingDeck = deck;
        self.cardCount = count;
        if(![self reset])
        {
            self = nil;
        }
    }
    return self;
}

-(Card *)cardAtIndex:(NSUInteger)index
{
    return index < [self.cards count] ? self.cards[index] : nil;
}

#define MATCH_BONUS 4
#define MISMATCH_PENALTY 2
#define FLIP_COST 1
-(void)flipCardAtIndex:(NSUInteger)index
{
    Card *card = [self cardAtIndex:index];
    
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
                    int matchScore = [card match:@[otherCard]];
                    if(matchScore)
                    {
                        card.unplayable = YES;
                        otherCard.unplayable = YES;
                        self.score += matchScore * MATCH_BONUS;
                        self.descriptionOfLastFlip = [NSString stringWithFormat:@"Matched %@ and %@ for %d points.", card, otherCard, matchScore * MATCH_BONUS];
                    }
                    else
                    {
                        otherCard.faceUp = NO;
                        self.score -= MISMATCH_PENALTY;
                        self.descriptionOfLastFlip = [NSString stringWithFormat:@"%@ and %@ don't match! %d point penalty!", card, otherCard, MISMATCH_PENALTY];
                    }
                    break;
                }
            }
            self.score -= FLIP_COST;
        }
        card.faceUp = !card.isFaceUp;
    }
}

@end
