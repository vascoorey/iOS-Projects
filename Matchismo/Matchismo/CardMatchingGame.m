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
@property (nonatomic, strong) GameSettings *settings;
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

-(id)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck andGameSettings:(GameSettings *)settings
{
    if((self = [super init]))
    {
        _playingDeck = deck;
        _cardCount = count;
        _defaultMatchMode = YES;
        _score = 0;
        _descriptionOfLastFlip = @"Last flip.";
        _cards = [[NSMutableArray alloc] init];
        _settings = settings;
        for(int i = 0; i < _cardCount; i++)
        {
            Card *card = [_playingDeck drawRandomCard];
            if(card)
            {
                _cards[i] = card;
            }
            else
            {
                self = nil;
                break;
            }
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

-(void)flipCardAtIndex:(NSUInteger)index
{
    Card *card = [self cardAtIndex:index];
    NSLog(@"%@", card);
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
                    self.score += matchScore * self.settings.matchBonus * [matches count];
                    self.descriptionOfLastFlip = [NSString stringWithFormat:@"Matched %@", card];
                    for(Card *otherCard in matches)
                    {
                        otherCard.unplayable = YES;
                        self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@", %@", otherCard]];
                    }
                    self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@" for %d points.", matchScore * self.settings.matchBonus * [matches count]]];
                }
                else
                {
                    self.score -= self.settings.mismatchPenalty;
                    self.descriptionOfLastFlip = [NSString stringWithFormat:@"%@", card];
                    for(Card *otherCard in matches)
                    {
                        self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@", %@", otherCard]];
                        otherCard.faceUp = NO;
                    }
                    self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@" dont match. %d point penalty.", matchScore - self.settings.mismatchPenalty]];
                }
            }
            [self.flipHistory addObject:self.descriptionOfLastFlip];
            self.score -= self.settings.flipCost;
        }
        card.faceUp = !card.isFaceUp;
    }
}

@end
