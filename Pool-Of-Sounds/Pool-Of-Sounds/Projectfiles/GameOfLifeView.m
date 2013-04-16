//
//  GameOfLifeView.m
//  Pool-Of-Sounds
//
//  Created by Vasco Orey on 4/16/13.
//
//

#import "GameOfLifeView.h"

@interface GameOfLifeView ()
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic) NSInteger numRows;
@property (nonatomic) NSInteger numCols;
@property (nonatomic) CGRect viewRect;
@end

@implementation GameOfLifeView

-(void)setRowToHighlight:(NSInteger)rowToHighlight
{
    if(rowToHighlight < 0 || rowToHighlight >= self.numRows)
    {
        rowToHighlight = 0;
    }
    _rowToHighlight = rowToHighlight;
}

-(id)initWithRect:(CGRect)rect rows:(NSInteger)rows cols:(NSInteger)cols cellWidth:(CGFloat)cellWidth
{
    if((self = [super init]))
    {
        self.numRows = rows;
        self.numCols = cols;
        self.viewRect = rect;
        self.cellWidth = cellWidth;
        self.cellBeingPlayedColor = ccc4FFromccc3B(ccRED);
        self.cellColor = ccc4FFromccc3B(ccBLUE);
    }
    return self;
}

-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col
{
    if([self.rows[row][col] integerValue])
    {
        self.rows[row][col] = @(0);
    }
    else
    {
        self.rows[row][col] = @(1);
    }
}

-(void)draw
{
    ccDrawSolidRect(self.viewRect.origin,
                    CGPointMake(self.viewRect.size.width, self.viewRect.size.height),
                    ccc4f(0, 1, 1, 1));
    
    //Set the color in RGB to draw the line with:
    ccDrawColor4B(100, 0, 255, 255); //purple, values range from 0 to 255
    
    //Draw row lines
    for(int row = 0; row <= self.numRows; row ++)
    {
        //and now draw a line between them!
        ccDrawLine(CGPointMake(
                               self.viewRect.origin.x,
                               self.viewRect.origin.y + (row * self.cellWidth)
                               ),
                   CGPointMake(
                               self.viewRect.size.width,
                               self.viewRect.origin.y + (row * self.cellWidth)
                               ));
    }
    
    // Draw column lines
    for(int col = 0; col <= self.numCols; col ++)
    {
        //and now draw a line between them!
        ccDrawLine(CGPointMake(
                               self.viewRect.origin.x + (col * self.cellWidth),
                               self.viewRect.origin.y
                               ),
                   CGPointMake(
                               self.viewRect.origin.x + (col * self.cellWidth),
                               self.viewRect.size.height
                               ));
    }
    
    //Fill in active locations in the gameGrid
    for(int row = 0; row < self.numRows && self.rows; row ++)
    {
        for(int col = 0; col < self.numCols && self.rows[row]; col ++)
        {
            NSInteger cellValue = [self.rows[row][col] integerValue];
            if(cellValue)
            {
                ccDrawSolidRect(
                                CGPointMake(
                                            self.viewRect.origin.x + col * self.cellWidth,
                                            self.viewRect.origin.y + row * self.cellWidth),
                                CGPointMake(
                                            self.viewRect.origin.x + (col + 1) * self.cellWidth,
                                            self.viewRect.origin.y + (row + 1) * self.cellWidth),
                                (row == self.rowToHighlight ? self.cellBeingPlayedColor : self.cellColor)
                                );
            }
        }
    }
}

@end
