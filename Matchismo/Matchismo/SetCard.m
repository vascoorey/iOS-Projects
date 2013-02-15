//
//  SetCard.m
//  Matchismo
//
//  Created by Vasco Orey on 2/14/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "SetCard.h"

@implementation SetCard

@synthesize shape = _shape;

-(BOOL)checkMatchWithFirstCard:(SetCard *)firstCard andSecondCard:(SetCard *)secondCard
{
    return
    ((self.numShapes == firstCard.numShapes && self.numShapes == secondCard.numShapes) ||
     (self.numShapes != firstCard.numShapes && self.numShapes != secondCard.numShapes && firstCard.numShapes != secondCard.numShapes)) &&
    ((self.shade == firstCard.shade && self.shade == secondCard.shade) ||
     (self.shade != firstCard.shade && self.shade != secondCard.shade && firstCard.shade != secondCard.shade)) &&
    (([self.shape isEqualToString:firstCard.shape] && [self.shape isEqualToString:secondCard.shape]) ||
     (![self.shape isEqualToString:firstCard.shape] && ![self.shape isEqualToString:secondCard.shape] && ![firstCard.shape isEqualToString:secondCard.shape])) &&
    ((self.color == firstCard.color && self.color == secondCard.color) ||
     (self.color != firstCard.color && self.color != secondCard.color && firstCard.color != secondCard.color));
}

-(int)match:(NSArray *)otherCards
{
    int score = 0;
    /*
     * A Set match must satisfy all these conditions:
     *
     *  1) All cards have the same number of symbols OR 3 diferent numbers
     *  2) All cards have the same symbol OR 3 diferent symbols
     *  3) All cards have the same shading OR 3 diferent shadings
     *  4) All cards have the same color OR 3 diferent colors
     *  5) There are exactly 3 cards.
     */
    if([otherCards count] == 2 && [self checkMatchWithFirstCard:otherCards[0] andSecondCard:otherCards[1]])
    {
        NSLog(@"Match!");
        score = 1;
    }
    return score;
}

-(NSString *)description
{
    NSString *description = @"";
    for(int i = 0; i < self.numShapes; i ++)
    {
        description = [description stringByAppendingFormat:@" %@", self.shape];
    }
    return self.numShapes ? description : @"?";
}

-(void)setShape:(NSString *)shape
{
    if([[SetCard validShapes] containsObject:shape])
    {
        _shape = shape;
    }
}

-(NSString *)shape
{
    return _shape;
}

-(void)setShade:(int)shade
{
    if(shade > 0 && shade <= [SetCard maxShade])
    {
        _shade = shade;
    }
}

-(float)shadeValue
{
    return self.shade == [SetCard maxShade] ? 1.0f : (float)(self.shade - 1) / [SetCard maxShade];
}

-(void)setColor:(int)color
{
    if(color > 0 && color <= [SetCard maxColor])
    {
        _color = color;
    }
}

-(void)setNumShapes:(int)numShapes
{
    if(numShapes > 0 && numShapes <= [SetCard maxShapes])
    {
        _numShapes = numShapes;
    }
}

-(NSString *)contents
{
    return self.shape;
}

+(NSArray *)validShapes
{
    return @[@"▲", @"●", @"■"];
}

+(int)maxShapes
{
    return 3;
}

+(int)maxShade
{
    return 3;
}

+(int)maxColor
{
    return 3;
}

@end
