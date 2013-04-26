//
//  GridView.m
//  SoundGrid
//
//  Created by Vasco Orey on 4/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "GridView.h"

@interface GridView ()
@property (nonatomic) NSUInteger lastNumRows;
@property (nonatomic) NSUInteger lastNumCols;
@property (nonatomic, readwrite) CGFloat cellSide;
@property (nonatomic, readwrite) CGFloat xPadding;
@property (nonatomic, readwrite) CGFloat yPadding;
@property (nonatomic) BOOL onlyDrawCell;
@property (nonatomic) NSInteger rowToDraw;
@property (nonatomic) NSInteger colToDraw;
@property (nonatomic) NSInteger colorToDraw;
@end

@implementation GridView

#define GRID_NUM_COLORS 4

-(void)setGrid:(NSMutableArray *)gridArray
{
    NSUInteger rows = [gridArray count];
    NSUInteger cols = [gridArray[0] count];
    if(rows != self.lastNumRows || cols != self.lastNumCols)
    {
        self.lastNumRows = rows;
        self.lastNumCols = cols;
        CGFloat cellWidth = self.bounds.size.width / cols;
        CGFloat cellHeight = self.bounds.size.height / rows;
        self.cellSide = (cellWidth > cellHeight) ? cellHeight : cellWidth;
        self.yPadding = (cellWidth > cellHeight) ? 0.0f : (self.bounds.size.height - (rows * cellWidth)) / 2;
        self.xPadding = (cellWidth > cellHeight) ? (self.bounds.size.width - (cols * cellHeight)) / 2 : 0.0f;
    }
    _grid = gridArray;
    self.onlyDrawCell = NO;
    [self setNeedsDisplay];
}

-(id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        self.multipleTouchEnabled = NO;
    }
    return self;
}

-(UIColor *)colorForNumber:(int)number
{
    switch (number) {
        case 1:
            return [UIColor blueColor];
            break;
        case 2:
            return [UIColor greenColor];
            break;
        case 3:
            return [UIColor yellowColor];
            break;
        case 4:
            return [UIColor redColor];
            break;
        default:
            return [UIColor clearColor];
            break;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSUInteger numRows = [self.grid count];
    CGRect cellRect = CGRectMake(0, 0, self.cellSide, self.cellSide);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    if(!self.onlyDrawCell || (CGRectContainsRect(rect, self.bounds) && CGRectContainsRect(self.bounds, rect)))
    {
        self.onlyDrawCell = NO;
        for(NSUInteger row = 0; row < numRows; row ++)
        {
            NSUInteger numCols = [self.grid[row] count];
            for(NSUInteger col = 0; col < numCols; col ++)
            {
                cellRect.origin.x = self.xPadding + (col * self.cellSide);
                cellRect.origin.y = self.yPadding + (row * self.cellSide);
                UIColor *color = [self colorForNumber:[self.grid[row][col] intValue]];
                CGContextSetFillColorWithColor(context, [color CGColor]);
                CGContextStrokeRect(context, cellRect);
                CGContextFillRect(context, cellRect);
            }
        }
    }
    else
    {
        CGContextSetFillColorWithColor(context, [[self colorForNumber:self.colorToDraw] CGColor]);
        CGContextSetLineWidth(context, 1.5);
        CGContextStrokeRect(context, rect);
        CGContextFillRect(context, rect);
        self.onlyDrawCell = NO;
    }
}

-(void)activateRow:(NSInteger)row col:(NSInteger)col color:(NSInteger)color
{
    self.grid[row][col] = @(color);
    CGRect cellRect = CGRectMake(
                                 self.bounds.origin.x + self.xPadding + col * self.cellSide,
                                 self.bounds.origin.y + self.yPadding + row * self.cellSide,
                                 self.cellSide,
                                 self.cellSide
                                 );
    self.onlyDrawCell = YES;
    self.rowToDraw = row;
    self.colToDraw = col;
    self.colorToDraw = color;
    [self setNeedsDisplayInRect:cellRect];
}

#warning collapse repeated stuff into a function
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UITouch *touch = (UITouch *)obj;
        CGPoint location = [touch locationInView:self];
        NSInteger row = (location.y - self.yPadding) / self.cellSide;
        NSInteger col = (location.x - self.xPadding) / self.cellSide;
        if(row >= 0 && row < self.lastNumRows &&
           col >= 0 && col < self.lastNumCols)
        {
            [self.delegate didDetectTouchAtRow:row col:col started:YES];
        }
    }];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UITouch *touch = (UITouch *)obj;
        CGPoint location = [touch locationInView:self];
        NSInteger row = (location.y - self.yPadding) / self.cellSide;
        NSInteger col = (location.x - self.xPadding) / self.cellSide;
        if(row >= 0 && row < self.lastNumRows &&
           col >= 0 && col < self.lastNumCols)
        {
            [self.delegate didDetectTouchAtRow:row col:col started:NO];
        }
    }];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
