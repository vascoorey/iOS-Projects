//
//  SetCardDeck.m
//  Matchismo
//
//  Created by Vasco Orey on 2/14/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "SetCardDeck.h"
#import "SetCard.h"

@implementation SetCardDeck

-(id)init
{
    if((self = [super init]))
    {
        for(int shape = 1; shape <= [SetCard numberOfShapes]; shape ++)
        {
            for(int color = 1; color <= [SetCard maxColor]; color ++)
            {
                for(int shade = 1; shade <= [SetCard maxShade]; shade ++)
                {
                    for(int numShapes = 1; numShapes <= [SetCard maxShapes]; numShapes ++)
                    {
                        SetCard *setCard = [[SetCard alloc] init];
                        setCard.shape = shape;
                        setCard.color = color;
                        setCard.shade = shade;
                        setCard.numberOfShapes = numShapes;
                        setCard.faceUp = NO;
                        [self addCard:setCard atTop:YES];
                    }
                }
            }
        }
    }
    return self;
}

@end
