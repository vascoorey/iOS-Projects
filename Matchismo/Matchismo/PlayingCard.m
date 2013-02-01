//
//  PlayingCard.m
//  Matchismo
//
//  Created by Vasco Orey on 2/1/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

@synthesize suit = _suit;

-(NSString *)contents
{
    // Equivalent to [NSArray arrayWithObjects:b...]
    NSArray *rankOfStrings = @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
    return [rankOfStrings[self.rank] stringByAppendingString:self.suit];
}

-(void)setSuit:(NSString *)suit
{
    if([[PlayingCard validSuits] containsObject:suit])
    {
        _suit = suit;
    }
}

-(NSString *)suit
{
    return _suit ? _suit : @"?";
}

-(void)setRank:(NSUInteger)rank
{
    if(rank <= [PlayingCard maxRank])
    {
        _rank = rank;
    }
}

+(NSArray *)rankStrings
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+(NSUInteger)maxRank
{
    return [self rankStrings].count - 1;
}

+(NSArray *)validSuits
{
    return @[@"♣",@"♥",@"♦",@"♠"];
}

@end
