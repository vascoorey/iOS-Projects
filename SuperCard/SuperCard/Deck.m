//
//  Deck.m
//  Matchismo
//
//  Created by Vasco Orey on 2/1/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Deck.h"

@interface Deck()
@property (nonatomic, strong) NSMutableArray *cards;
@end

@implementation Deck

-(NSMutableArray *)cards
{
    if(!_cards)
    {
        _cards = [[NSMutableArray alloc] init];
    }
    return _cards;
}

-(void)addCard:(Card *)card atTop:(BOOL)atTop
{
    if(card)
    {
        if(atTop)
        {
            [self.cards insertObject:card atIndex:0];
        }
        else
        {
            [self.cards addObject:card];
        }
    }
}

-(Card *)drawRandomCard
{
    Card *randomCard = nil;
    
    if(self.cards.count)
    {
        unsigned index = arc4random() % self.cards.count;
        randomCard = self.cards[index]; // equivalent to [self.cards objectAtIndex:index]
        [self.cards removeObjectAtIndex:index];
    }
    
    return randomCard;
}

@end
