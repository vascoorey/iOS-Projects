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

-(int)match:(NSArray *)otherCards
{
    int score = 0;
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    
    if([otherCards count])
    {
        for(id otherCard in otherCards)
        {
            if([otherCard isKindOfClass:[PlayingCard class]])
            {
                PlayingCard *otherPlayingCard = (PlayingCard *)otherCard;
                if([otherPlayingCard.suit isEqualToString:self.suit] && (![matches count] || [otherPlayingCard match:matches]))
                {
                    score += 1;
                }
                else if(otherPlayingCard.rank == self.rank && (![matches count] || [otherPlayingCard match:matches]))
                {
                    score += 4;
                }
                else
                {
                    NSLog(@"No match for %@ and %@!", self, otherCard);
                    score = 0;
                    break;
                }
                [matches addObject:otherPlayingCard];
            }
            else
            {
                NSLog(@"Tring to match against non-playing cards!");
                score = 0;
                break;
            }
        }
    }
    
    return score;
}

-(NSString *)contents
{
    return [[PlayingCard rankStrings][self.rank] stringByAppendingString:self.suit];
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
    // Equivalent to [NSArray arrayWithObjects:b...]
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+(NSUInteger)maxRank
{
    return [[self rankStrings] count] - 1;
}

+(NSArray *)validSuits
{
    return @[@"♣",@"♥",@"♦",@"♠"];
}

@end
