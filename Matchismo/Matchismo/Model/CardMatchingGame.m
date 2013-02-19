//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Vasco Orey on 2/1/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CardMatchingGame.h"
#import "AllGameSettings.h"

@interface CardMatchingGame ()
@property (readwrite, nonatomic) NSInteger score;
@property (readwrite, nonatomic) NSString *descriptionOfLastFlip;
@property (nonatomic, strong) NSArray *cardsForLastFlip;
@property (nonatomic, strong) NSMutableArray *flipHistory;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) Deck *playingDeck;
@property (nonatomic, strong) NSString *name;
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

-(id)initWithDeck:(Deck *)deck name:(NSString *)name settings:(GameSettings *)settings
{
    if((self = [super init]))
    {
        _playingDeck = deck;
        _score = 0;
        _descriptionOfLastFlip = @"Last flip.";
        _cards = [[NSMutableArray alloc] init];
        _name = name;
        // Only set settings if they don't exist
        if(![AllGameSettings settingsForGame:_name])
        {
            [AllGameSettings setSettings:settings forGame:_name];
        }
        else
        {
            settings = [AllGameSettings settingsForGame:_name];
        }
        for(int i = 0; i < settings.startingCardCount; i++)
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
    return index < [self.cards count] || index >= [self.cards count] ? self.cards[index] : nil;
}

-(void)flipCardAtIndex:(NSUInteger)index
{
    Card *card = [self cardAtIndex:index];
    
    GameSettings *settings = [AllGameSettings settingsForGame:self.name];
    NSAssert(settings, @"Couldn't find setting for %@", self.name);
    
    int matchScore = 0;
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    
    if(card && !card.isUnplayable)
    {
#warning This needs to work for various matching schemes: for 3 or more cards this needs to show the last n selected.
        self.descriptionOfLastFlip = [NSString stringWithFormat:@"Flipped %@ ", card];
        if(!card.isFaceUp)
        {
            // Check for what cards we'll be matching
            for(Card *otherCard in self.cards)
            {
                if(otherCard.isFaceUp && !otherCard.isUnplayable && ![otherCard isEqual:card])
                {
                    [matches addObject:otherCard];
                    if([matches count] + 1 == settings.matchMode)
                    {
                        break;
                    }
                }
            }
            
            if([matches count] + 1 == settings.matchMode)
            {
                // Calculate
                matchScore = [card match:matches];
                if(matchScore)
                {
                    card.unplayable = YES;
                    self.score += matchScore * settings.matchBonus * [matches count];
                    self.descriptionOfLastFlip = [NSString stringWithFormat:@"Matched %@", card];
                    for(Card *otherCard in matches)
                    {
                        otherCard.unplayable = YES;
                        self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@"& %@ ", otherCard]];
                    }
                    self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@". %d points", matchScore * settings.matchBonus * [matches count]]];
                }
                else
                {
                    self.score -= settings.mismatchPenalty;
                    self.descriptionOfLastFlip = [NSString stringWithFormat:@"%@", card];
                    for(Card *otherCard in matches)
                    {
                        self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@"& %@ ", otherCard]];
                        otherCard.faceUp = NO;
                    }
                    self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@" dont match. %d points", matchScore - settings.mismatchPenalty]];
                }
            }
            [self.flipHistory addObject:self.descriptionOfLastFlip];
            // Mainly used for the Set game as we need to know what cards were chosen
            [matches addObject:card];
            self.cardsForLastFlip = matches;
            self.score -= settings.flipCost;
            if(matchScore && settings.shouldRedealCards)
            {
                for(Card *card in matches)
                {
                    if(card.isUnplayable)
                    {
                        Card *newCard = [self.playingDeck drawRandomCard];
                        if(newCard)
                        {
                            [self.cards replaceObjectAtIndex:[self.cards indexOfObject:card] withObject:newCard];
                        }
                    }
                }
            }
        }
        card.faceUp = !card.isFaceUp;
    }
}

@end
