//
//  Cells.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 5/24/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Cells.h"

@interface Cells ()
@property (nonatomic) NSUInteger seed;
@property (nonatomic, strong) NSMutableArray *grid;
@end

@implementation Cells

-(NSMutableArray *)grid
{
    if(!_grid)
    {
        _grid = [NSMutableArray arrayWithCapacity:self.numRows];
    }
    return _grid;
}

-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols seed:(NSUInteger)seed
{
    if((self = [super init]))
    {
        self.numRows = rows;
        self.numCols = cols;
        [self reset];
    }
    return self;
}

-(void)reset
{
    //Set the random seed - enables repetition of found patterns
    srand(self.seed);
}

-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started species:(NSInteger)species
{
    
}

@end
