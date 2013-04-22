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
@end

@implementation GridView

#define GRID_NUM_COLORS 4

-(void)setGrid:(NSArray *)gridArray
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
    [self setNeedsDisplay];
}

-(id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        self.multipleTouchEnabled = YES;
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
    NSUInteger numRows = [self.grid count];
    for(NSUInteger row = 0; row < numRows; row ++)
    {
        NSUInteger numCols = [self.grid[row] count];
        for(NSUInteger col = 0; col < numCols; col ++)
        {
            UIBezierPath *path = [[UIBezierPath alloc] init];
            [[UIColor blackColor] setStroke];
            [path setLineWidth:0.5];
            CGRect rect = CGRectMake(
                                     self.xPadding + (col * self.cellSide),
                                     self.yPadding + (row * self.cellSide),
                                     self.cellSide,
                                     self.cellSide
                                     );
            [[self colorForNumber:[self.grid[row][col] intValue]] setFill];
            [self addRect:rect toPath:path];
            [path fill];
            [path stroke];
        }
    }
}

-(void)addRect:(CGRect)rect toPath:(UIBezierPath *)path
{
    CGPoint point = rect.origin;
    [path moveToPoint:point];
    point.x += rect.size.width;
    [path addLineToPoint:point];
    point.y += rect.size.height;
    [path addLineToPoint:point];
    point.x = rect.origin.x;
    [path addLineToPoint:point];
    [path addLineToPoint:rect.origin];
    [path closePath];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
