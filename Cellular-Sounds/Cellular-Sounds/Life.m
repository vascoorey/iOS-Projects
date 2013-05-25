//
//  Life.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 5/24/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Life.h"

@implementation Life

-(void)reset
{
    NSAssert(false, @"%s", __PRETTY_FUNCTION__);
}

-(void)performStep
{
    NSAssert(false, @"%s", __PRETTY_FUNCTION__);
}

-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started
{
    NSAssert(false, @"%s", __PRETTY_FUNCTION__);
}

-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started species:(NSInteger)species
{
    NSAssert(false, @"%s", __PRETTY_FUNCTION__);
}


-(NSInteger)previousRow:(NSInteger)row
{
    //Wrap around if row == 0
    if(!row)
    {
        return self.numRows - 1;
    }
    else
    {
        return (row - 1) % self.numRows;
    }
}

-(NSInteger)previousCol:(NSInteger)col
{
    if(!col)
    {
        return self.numCols - 1;
    }
    else
    {
        return (col - 1) % self.numCols;
    }
}

-(NSInteger)nextRow:(NSInteger)row
{
    if(row == self.numRows - 1)
    {
        return 0;
    }
    else
    {
        return (row + 1) % self.numRows;
    }
}

-(NSInteger)nextCol:(NSInteger)col
{
    if(col == self.numCols - 1)
    {
        return 0;
    }
    else
    {
        return (col + 1) % self.numCols;
    }
}

@end
