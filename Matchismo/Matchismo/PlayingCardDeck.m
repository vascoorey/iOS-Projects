//
//  PlayingCardDeck.m
//  Matchismo
//
//  Created by Vasco Orey on 2/1/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@implementation PlayingCardDeck

-(id)init
{
    if((self = [super init]))
    {
        for(NSString *suit in [PlayingCard validSuits])
        {
            for(NSUInteger rank = 1; rank <= [PlayingCard maxRank]; rank ++)
            {
                PlayingCard *card = [[PlayingCard alloc] init];
                card.rank = rank;
                card.suit = suit;
                [self addCard:card atTop:YES];
            }
        }
    }
    return self;
}

@end
