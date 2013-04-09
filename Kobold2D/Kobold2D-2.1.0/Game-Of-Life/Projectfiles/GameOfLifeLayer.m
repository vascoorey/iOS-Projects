/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "GameOfLifeLayer.h"

@interface GameOfLifeLayer ()
@property (nonatomic, strong) NSMutableArray *gameGrid;
@property (nonatomic, strong) NSMutableArray *gameNeighbors;
@property (nonatomic) BOOL done;
@property (nonatomic) NSUInteger priorCol;
@property (nonatomic) NSUInteger priorRow;
@end

@implementation GameOfLifeLayer

#define Y_OFF_SET 21
#define WIDTH_WINDOW 320
#define HEIGHT_WINDOW 480
#define CELL_WIDTH 20
#define WIDTH_GAME WIDTH_WINDOW
#define HEIGHT_GAME (HEIGHT_WINDOW - 60)
#define NUM_ROWS (HEIGHT_GAME / CELL_WIDTH)
#define NUM_COLS (WIDTH_GAME / CELL_WIDTH)
#define DELAY_IN_SECONDS 0.15f

-(NSMutableArray *)gameNeighbors
{
    if(!_gameNeighbors)
    {
        _gameNeighbors = [[NSMutableArray alloc] initWithCapacity:NUM_ROWS];
    }
    return _gameNeighbors;
}

-(NSMutableArray *)gameGrid
{
    if(!_gameGrid)
    {
        _gameGrid = [[NSMutableArray alloc] initWithCapacity:NUM_ROWS];
    }
    return _gameGrid;
}

-(id) init
{
	if ((self = [super init]))
	{
        [self reset];
        [self scheduleUpdate];
	}
	return self;
}

-(void)reset
{
    self.gameGrid = nil;
    self.gameNeighbors = nil;
    self.priorCol = -1;
    self.priorRow = -1;
    for(int row = 0; row < NUM_ROWS; row ++)
    {
        NSMutableArray *line = [[NSMutableArray alloc] initWithCapacity:NUM_COLS];
        for(int col = 0; col < NUM_COLS; col ++)
        {
            line[col] = @(0);
        }
        self.gameGrid[row] = line;
        self.gameNeighbors[row] = [line mutableCopy];
    }
}

-(NSUInteger)previousRow:(NSUInteger)row
{
    //Wrap around if row == 0
    return (row - 1) % NUM_ROWS;
}

-(NSUInteger)previousCol:(NSUInteger)col
{
    return (col - 1) % NUM_COLS;
}

-(NSUInteger)nextRow:(NSUInteger)row
{
    return (row + 1) % NUM_ROWS;
}

-(NSUInteger)nextCol:(NSUInteger)col
{
    return (col + 1) % NUM_COLS;
}

-(void)update:(ccTime)delta
{
    //React to touch input
    KKInput *input = [KKInput sharedInput];
    if(input.touchesAvailable)
    {
        KKTouch *touch;
        CCARRAY_FOREACH(input.touches, touch)
        {
            CGPoint touchLocation = touch.location;
            if(touch.phase == KKTouchPhaseBegan)
            {
                //Handle touches on the right button
                if(touchLocation.x >= WIDTH_WINDOW / 2 && touchLocation.y > HEIGHT_GAME + Y_OFF_SET)
                {
                    self.done = !self.done;
                }
                //Handle touches on the left button
                else if(touchLocation.x < WIDTH_WINDOW / 2 && touchLocation.y > HEIGHT_GAME + Y_OFF_SET)
                {
                    [self reset];
                    self.done = YES;
                }
                else
                {
                    NSUInteger row = touchLocation.y / CELL_WIDTH;
                    NSUInteger col = touchLocation.x / CELL_WIDTH;
                    NSUInteger previousValue = [self.gameGrid[row][col] unsignedIntValue];
                    self.gameGrid[row][col] = previousValue ? @(0) : @(1);
                    self.priorCol = col;
                    self.priorRow = row;
                }
            }
            else if(touchLocation.y <= HEIGHT_GAME + Y_OFF_SET)
            {
                NSUInteger row = touchLocation.y / CELL_WIDTH;
                NSUInteger col = touchLocation.x / CELL_WIDTH;
                if(self.priorRow != row || self.priorCol != col)
                {
                    NSUInteger previousValue = [self.gameGrid[row][col] unsignedIntValue];
                    NSLog(@"Cell pressed: %d, %d", row, col);
                    self.gameGrid[row][col] = previousValue ? @(0) : @(1);
                    self.priorCol = col;
                    self.priorRow = row;
                }
            }
        }
        
    }
}

-(void) draw
{
    ccDrawSolidRect(CGPointMake(0, 0),
                    CGPointMake(WIDTH_GAME, HEIGHT_GAME),
                    ccc4f(0, 1, 1, 1));
    
    //Set the color in RGB to draw the line with:
    ccDrawColor4B(100, 0, 255, 255); //purple, values range from 0 to 255
    
    //Draw row lines
    for(int row = 0; row < NUM_ROWS; row ++)
    {
        //and now draw a line between them!
        ccDrawLine(CGPointMake(0,row * CELL_WIDTH),
                   CGPointMake(WIDTH_GAME, row * CELL_WIDTH));
    }
    
    // Draw column lines
    for(int col = 0; col < NUM_COLS; col ++)
    {
        //and now draw a line between them!
        ccDrawLine(CGPointMake(col * CELL_WIDTH, 0),
                   CGPointMake(col * CELL_WIDTH, HEIGHT_GAME));
    }
    
    //Fill in active locations in the gameGrid
    for(int row = 0; row < NUM_ROWS; row ++)
    {
        for(int col = 0; col < NUM_COLS; col ++)
        {
            NSUInteger cellValue = [self.gameGrid[row][col] unsignedIntValue];
            if(cellValue)
            {
                ccDrawSolidRect(CGPointMake(col * CELL_WIDTH, row * CELL_WIDTH),
                                CGPointMake(col * CELL_WIDTH + CELL_WIDTH, row * CELL_WIDTH + CELL_WIDTH),
                                ccc4f(100.0/255.0, 0, 1.0, 1.0));
            }
        }
    }
    
    //Draw the button
    ccDrawSolidRect(CGPointMake(WIDTH_WINDOW / 2, HEIGHT_GAME + Y_OFF_SET),
                    CGPointMake(WIDTH_WINDOW, HEIGHT_WINDOW),
                    ccc4f(150.0/255.0, 0.0, 1.0, 1.0));
    
    //Draw the clear button
    ccDrawSolidRect(CGPointMake(0, HEIGHT_GAME + Y_OFF_SET),
                    CGPointMake(WIDTH_WINDOW / 2, HEIGHT_WINDOW),
                    ccc4f(50.0/255.0, 0.0, 1.0, 1.0));
}

@end
