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
     */
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
    if(shade >= 0 && shade < [SetCard maxShade])
    {
        _shade = shade;
    }
}

-(void)setColor:(int)color
{
    if(color >= 0 && color < [SetCard maxColor])
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
    return 2;
}

+(int)maxColor
{
    return 4;
}

@end
