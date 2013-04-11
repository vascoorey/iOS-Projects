//
//  Cell.m
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/11/13.
//
//

#import "Cell.h"

@implementation Cell

#define STARTING_LIFE 5 //5 steps

-(id)initWithRow:(NSInteger)row col:(NSInteger)col
{
    if((self = [super init]))
    {
        self.row = row;
        self.col = col;
        self.life = STARTING_LIFE;
    }
    return self;
}

+(Cell *)cellWithRow:(NSInteger)row col:(NSInteger)col
{
    return [[self alloc] initWithRow:row col:col];
}

@end
