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
@property (nonatomic, strong, readwrite) NSMutableArray *cards;
@property (nonatomic, strong) Deck *deck;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, readwrite) BOOL hadMatch;
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

-(NSInteger)cardsInPlay
{
    return [self.cards count];
}

-(void)setHadMatch:(BOOL)hadMatch
{
    _hadMatch = hadMatch;
    if(_hadMatch)
    {
        self.score -= [AllGameSettings settingsForGame:self.name].mismatchPenalty;
    }
}

-(BOOL)hasUnplayableCards
{
    for(int i = 0; i < [self.cards count]; i++)
    {
        if(((Card *)self.cards[i]).isUnplayable)
        {
            return YES;
        }
    }
    return NO;
}

// Only works for 2 or 3 match
-(NSArray *)indicesForMatch
{
    int matchMode = [AllGameSettings settingsForGame:self.name].matchMode;
    NSAssert(matchMode == 2 || matchMode == 3, @"indicesForMatch will only work for a match mode of 3");
    if([self.cards count] < matchMode)
    {
        return nil;
    }
    else
    {
        for(NSUInteger i = 0; i < [self.cards count]; i ++)
        {
            for(NSUInteger j = (i + 1); j < [self.cards count]; j ++)
            {
                if(matchMode == 2)
                {
                    if([((Card*)self.cards[i]) match:@[self.cards[j]]])
                    {
                        ((Card *)self.cards[i]).markedForCheating = YES;
                        ((Card *)self.cards[j]).markedForCheating = YES;
                        return @[@(i), @(j)];
                    }
                }
                else
                {
                    for(NSUInteger k = (j + 1); k < [self.cards count]; k ++)
                    {
                        if([((Card*)self.cards[i]) match:@[self.cards[j],self.cards[k]]])
                        {
                            ((Card *)self.cards[i]).markedForCheating = YES;
                            ((Card *)self.cards[j]).markedForCheating = YES;
                            ((Card *)self.cards[k]).markedForCheating = YES;
                            return @[@(i), @(j), @(k)];
                        }
                    }
                }
            }
        }
    }
    return nil;
}

-(id)initWithDeck:(Deck *)deck name:(NSString *)name
{
    if((self = [super init]))
    {
        _deck = deck;
        _score = 0;
        _descriptionOfLastFlip = @" ";
        _cards = [[NSMutableArray alloc] init];
        _name = name;
        // Only set settings if they don't exist
        GameSettings *settings = [AllGameSettings settingsForGame:_name];
        NSAssert(settings, @"Could not find settings for: %@", _name);
        for(int i = 0; i < settings.startingCardCount; i++)
        {
            Card *card = [_deck drawRandomCard];
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
        if(card.isFaceUp)
        {
            self.descriptionOfLastFlip = @" ";
        }
        else
        {
            if(![self.descriptionOfLastFlip isEqualToString:@" "])
            {
                self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingFormat:@", %@ ", card];
            }
            else
            {
                self.descriptionOfLastFlip = [NSString stringWithFormat:@"%@ ", card];
            }
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
                    //self.descriptionOfLastFlip = [NSString stringWithFormat:@"Matched %@", card];
                    for(Card *otherCard in matches)
                    {
                        otherCard.unplayable = YES;
                        //self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@"& %@ ", otherCard]];
                    }
                    self.descriptionOfLastFlip = [NSString stringWithFormat:@"%d points", matchScore * settings.matchBonus * [matches count]];
                }
                else
                {
                    self.score -= settings.mismatchPenalty;
                    //self.descriptionOfLastFlip = [NSString stringWithFormat:@"%@", card];
                    for(Card *otherCard in matches)
                    {
                        //self.descriptionOfLastFlip = [self.descriptionOfLastFlip stringByAppendingString:[NSString stringWithFormat:@"& %@ ", otherCard]];
                        otherCard.faceUp = NO;
                    }
                    self.descriptionOfLastFlip = [NSString stringWithFormat:@"%d points", matchScore - settings.mismatchPenalty];
                }
            }
            [self.flipHistory addObject:self.descriptionOfLastFlip];
            // Mainly used for the Set game as we need to know what cards were chosen
            [matches addObject:card];
            self.cardsForLastFlip = matches;
            self.score -= settings.flipCost;
            /*if(matchScore && settings.shouldRedealCards)
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
            }*/
        }
        card.faceUp = !card.isFaceUp;
    }
}

// Of NSNumber
-(NSArray *)requestCards:(NSUInteger)cards
{
    NSArray *matches = [AllGameSettings settingsForGame:self.name].penalizeCheating ? [self indicesForMatch] : nil;
    if(matches)
    {
        self.hadMatch = YES;
        for(NSNumber *index in matches)
        {
            ((Card *)self.cards[index.unsignedIntValue]).markedForCheating = NO;
        }
    }
    else
    {
        self.hadMatch = NO;
    }
    NSMutableArray *indices = [[NSMutableArray alloc] init];
    for(int i = 0; i < cards; i ++)
    {
        Card *card = [self.deck drawRandomCard];
        if(card)
        {
            [self.cards addObject:card];
            [indices addObject:@([self.cards indexOfObject:card])];
        }
    }
    return [indices copy];
}

// Of NSNumber
-(NSArray *)removeUnplayableCards
{
    NSMutableArray *indices = [[NSMutableArray alloc] init];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for(Card *card in self.cards)
    {
        if(card.isUnplayable)
        {
            NSUInteger index = [self.cards indexOfObject:card];
            [indices addObject:@(index)];
            [indexSet addIndex:index];
        }
    }
    [self.cards removeObjectsAtIndexes:indexSet];
    return [indices copy];
}

@end
