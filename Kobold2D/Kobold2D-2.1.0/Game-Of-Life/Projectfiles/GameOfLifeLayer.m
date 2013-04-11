/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "GameOfLifeLayer.h"
#import "SimpleAudioEngine.h"
#import "Cell.h"

@interface GameOfLifeLayer ()
@property (nonatomic, strong) NSMutableArray *gameGrid;
@property (nonatomic, strong) NSMutableArray *gameNeighbors;
@property (nonatomic, strong) NSMutableArray *gameFood;
@property (nonatomic) BOOL done;
//Define next grid update. Maybe a from an rng.
@property (nonatomic) ccTime nextUpdateTime;
@property (nonatomic) ccTime currentTime;
@property (nonatomic) NSInteger cellsCurrentlyActive;
@property (nonatomic) NSInteger foodCurentlyActive;
@property (nonatomic) NSInteger priorCol;
@property (nonatomic) NSInteger priorRow;
@property (nonatomic) ccColor4F toggleButtonColor;
@property (nonatomic) ccColor4F resetButtonColor;
@property (nonatomic, weak) CCLabelTTF *toggleLabel;
@property (nonatomic, strong) SimpleAudioEngine *audioEngine;
@end

@implementation GameOfLifeLayer

#define ARC4RANDOM_MAX 0x100000000
#define WIDTH_WINDOW (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 768 : 320)
#define HEIGHT_WINDOW (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1024 : 480)
#define Y_OFF_SET (HEIGHT_WINDOW * .04375f)
#define CELL_WIDTH (NSInteger)(WIDTH_WINDOW * .0625f)
#define WIDTH_GAME WIDTH_WINDOW
#define GAME_OFFSET (NSInteger)(HEIGHT_WINDOW * .125)
#define HEIGHT_GAME (HEIGHT_WINDOW - GAME_OFFSET)
#define NUM_ROWS (HEIGHT_GAME / CELL_WIDTH)
#define NUM_COLS (WIDTH_GAME / CELL_WIDTH)
#define DELAY_IN_SECONDS 0.15f //6.67 updates per second
#define FONT_SIZE 18.0f
#define TOGGLE_BUTTON_COLOR_NORMAL ccc4f(150.0/255.0, 0.0, 1.0, 1.0)
#define BUTTON_COLOR_PRESSED ccc4f(1.0, 0.0, 1.0, 1.0)
#define RESET_BUTTON_COLOR_NORMAL ccc4f(50.0/255.0, 0.0, 1.0, 1.0)
#define CELL_COLOR ccc4f(100.0/255.0, 0, 1.0, 1.0)
#define FOOD_COLOR ccc4f(188.0/255.0, 143.0/255.0, 143.0/255.0, 1.0) //188-143-143 = "Rosy Brown"

#pragma mark - Properties

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

-(NSMutableArray *)gameFood
{
    if(!_gameFood)
    {
        _gameFood = [[NSMutableArray alloc] initWithCapacity:NUM_ROWS];
    }
    return _gameFood;
}

-(void)setDone:(BOOL)done
{
    _done = done;
    if(done)
    {
        self.toggleButtonColor = BUTTON_COLOR_PRESSED;
        self.toggleLabel.string = @"Stopped";
    }
    else
    {
        self.toggleButtonColor = TOGGLE_BUTTON_COLOR_NORMAL;
        self.toggleLabel.string = @"Running";
    }
}

#pragma mark Lifecycle

-(id) init
{
	if ((self = [super init]))
	{
        self.audioEngine = [SimpleAudioEngine sharedEngine];
        [self.audioEngine preloadEffect:@"g-sound.WAV"];
        [self reset:NO];
        //[self schedule:@selector(nextStep) interval:DELAY_IN_SECONDS];
        [self scheduleUpdate];
        CCLabelTTF *resetButton = [CCLabelTTF labelWithString:@"Reset" fontName:@"Helvetica" fontSize:FONT_SIZE];
        resetButton.position = CGPointMake(WIDTH_WINDOW / 4, HEIGHT_WINDOW - Y_OFF_SET);
        self.toggleLabel = [CCLabelTTF labelWithString:@"Running" fontName:@"Helvetica" fontSize:FONT_SIZE];
        self.toggleLabel.position = CGPointMake((WIDTH_WINDOW / 4) * 3, HEIGHT_WINDOW - Y_OFF_SET);
        self.toggleButtonColor = TOGGLE_BUTTON_COLOR_NORMAL;
        [self addChild:resetButton];
        [self addChild:self.toggleLabel];
	}
	return self;
}

-(void)reset:(BOOL)withColorChange
{
    self.gameGrid = nil;
    self.gameNeighbors = nil;
    self.priorCol = -1;
    self.priorRow = -1;
    self.resetButtonColor = RESET_BUTTON_COLOR_NORMAL;
    for(int row = 0; row < NUM_ROWS; row ++)
    {
        NSMutableArray *line = [[NSMutableArray alloc] initWithCapacity:NUM_COLS];
        NSMutableArray *foodLine = [[NSMutableArray alloc] initWithCapacity:NUM_COLS];
        for(int col = 0; col < NUM_COLS; col ++)
        {
            foodLine[col] = @(0);
            if(arc4random() % 100 > 90)
            {
                self.foodCurentlyActive ++;
                foodLine[col] = @(1);
            }
            line[col] = @(0);
        }
        self.gameGrid[row] = line;
        self.gameNeighbors[row] = [line mutableCopy];
        self.gameFood[row] = foodLine;
    }
    if(withColorChange)
    {
        self.resetButtonColor = BUTTON_COLOR_PRESSED;
        [self scheduleOnce:@selector(resetButtonNormal) delay:DELAY_IN_SECONDS];
    }
}

-(void)resetButtonNormal
{
    self.resetButtonColor = RESET_BUTTON_COLOR_NORMAL;
}

#pragma mark Grid

-(void)nextStep
{
    if(!self.done)
    {
        //CFTimeInterval old = CACurrentMediaTime();
        [self countNeighbors];
        [self updateGrid];
        [self updateFood];
        //NSLog(@"Step time: %g", CACurrentMediaTime() - old);
    }
}

-(void)updateFood
{
    //Check if any cell is on a food cell, if so activate its adjacent cells.
    //Spawned cells should not spawn new cells
    NSMutableArray *cellsToSpawn = [[NSMutableArray alloc] init];
    for(int row = 0; row < NUM_ROWS; row ++)
    {
        for(int col = 0; col < NUM_COLS; col ++)
        {
            if([self.gameGrid[row][col] intValue] && [self.gameFood[row][col] intValue])
            {
                NSLog(@"Adding cell to spawn!");
                [cellsToSpawn addObject:[Cell cellWithRow:row col:col]];
                self.gameFood[row][col] = @(0);
            }
        }
    }
    for(Cell *cell in cellsToSpawn)
    {
        NSLog(@"Spawning cells at: %d, %d", cell.col, cell.row);
        self.gameGrid[[self previousRow:cell.row]][cell.col] = @(1);
        self.gameGrid[[self nextRow:cell.row]][cell.col] = @(1);
        self.gameGrid[cell.row][[self nextCol:cell.col]] = @(1);
        self.gameGrid[cell.row][[self previousCol:cell.col]] = @(1);
    }
}

-(void)countNeighbors
{
    for(int row = 0; row < NUM_ROWS; row ++)
    {
        for(int col = 0; col < NUM_COLS; col ++)
        {
            //Must test all 8 cells
            NSUInteger numNeighbors =
            [self.gameGrid[[self previousRow:row]][col] intValue] +
            [self.gameGrid[[self nextRow:row]][col] intValue] +
            [self.gameGrid[row][[self previousCol:col]] intValue] +
            [self.gameGrid[row][[self nextCol:col]] intValue] +
            [self.gameGrid[[self previousRow:row]][[self previousCol:col]] intValue] +
            [self.gameGrid[[self previousRow:row]][[self nextCol:col]] intValue] +
            [self.gameGrid[[self nextRow:row]][[self previousCol:col]] intValue] +
            [self.gameGrid[[self previousRow:row]][[self nextCol:col]] intValue];
            self.gameNeighbors[row][col] = @(numNeighbors);
        }
    }
}

-(void)updateGrid
{
    //Go through all the cells in gameNeighbors and change grid accordingly
    self.cellsCurrentlyActive = 1;
    for(int row = 0; row < NUM_ROWS; row ++)
    {
        for(int col = 0; col < NUM_COLS; col ++)
        {
            NSUInteger numNeighbors = [self.gameNeighbors[row][col] unsignedIntValue];
            if((numNeighbors <= 1) || (numNeighbors >= 4))
            {
                self.gameGrid[row][col] = @(0);
            }
            else if(numNeighbors == 3)
            {
                [self playSoundForRow:row col:col];
                self.gameGrid[row][col] = @(1);
                self.cellsCurrentlyActive ++;
            }
        }
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

-(void)playSoundForRow:(NSUInteger)row col:(NSUInteger)col
{
    Float32 pitch = ((440.0f / NUM_COLS) * (col + 1)) / 440.0f; //Based on column
    Float32 gain = ((row + 1.0f) / (3 * NUM_ROWS)) * (1.0f / self.cellsCurrentlyActive); //Based on row
    //NSLog(@"pitch: %g, gain: %g, active: %d", pitch, gain, self.cellsCurrentlyActive);
    [self.audioEngine playEffect:@"a-sound.WAV" pitch:pitch pan:0 gain:gain];
}

#pragma mark -

-(void)update:(ccTime)delta
{
    self.currentTime += delta;
    //Check if it's time for the next grid update
    if(self.currentTime > self.nextUpdateTime)
    {
        //Perform the next step
        [self nextStep];
        //Set the next update time
        ccTime nextDelta = (arc4random() % 100) / 100.0f;
        self.nextUpdateTime = self.currentTime + nextDelta;
        //NSLog(@"Next delta: %g, updating: %g", nextDelta, self.nextUpdateTime);
    }
    //React to touch input
    KKInput *input = [KKInput sharedInput];
    if(input.touchesAvailable)
    {
        KKTouch *touch;
        CCARRAY_FOREACH(input.touches, touch)
        {
            NSInteger row = -1;
            NSInteger col = -1;
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
                    [self reset:YES];
                }
                else
                {
                    row = touchLocation.y / CELL_WIDTH;
                    col = touchLocation.x / CELL_WIDTH;
                    NSUInteger previousValue = [self.gameGrid[row][col] unsignedIntValue];
                    [self playSoundForRow:row col:col];
                    self.gameGrid[row][col] = previousValue ? @(0) : @(1);
                    self.priorCol = col;
                    self.priorRow = row;
                }
            }
            else if(touchLocation.y <= HEIGHT_GAME + Y_OFF_SET)
            {
                row = touchLocation.y / CELL_WIDTH;
                col = touchLocation.x / CELL_WIDTH;
                if(self.priorRow != row || self.priorCol != col)
                {
                    [self playSoundForRow:row col:col];
                    NSUInteger previousValue = [self.gameGrid[row][col] unsignedIntValue];
                    if(previousValue)
                    {
                        self.gameGrid[row][col] = @(0);
                    }
                    else
                    {
                        self.gameGrid[row][col] = @(1);
                    }
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
            NSInteger cellValue = [self.gameGrid[row][col] intValue];
            NSInteger foodValue = [self.gameFood[row][col] intValue];
            if(cellValue || foodValue)
            {
                ccDrawSolidRect(CGPointMake(col * CELL_WIDTH, row * CELL_WIDTH),
                                CGPointMake((col + 1) * CELL_WIDTH, (row + 1) * CELL_WIDTH),
                                (cellValue ? CELL_COLOR : FOOD_COLOR));
            }
        }
    }
    
    //Draw the button
    ccDrawSolidRect(CGPointMake(WIDTH_WINDOW / 2, HEIGHT_GAME + Y_OFF_SET),
                    CGPointMake(WIDTH_WINDOW, HEIGHT_WINDOW),
                    self.toggleButtonColor);
    
    //Draw the clear button
    ccDrawSolidRect(CGPointMake(0, HEIGHT_GAME + Y_OFF_SET),
                    CGPointMake(WIDTH_WINDOW / 2, HEIGHT_WINDOW),
                    self.resetButtonColor);
}

@end
