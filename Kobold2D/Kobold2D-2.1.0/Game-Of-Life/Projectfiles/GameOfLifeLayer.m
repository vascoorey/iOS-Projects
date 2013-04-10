/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "GameOfLifeLayer.h"
#import "SimpleAudioEngine.h"

@interface GameOfLifeLayer ()
@property (nonatomic, strong) NSMutableArray *gameGrid;
@property (nonatomic, strong) NSMutableArray *gameNeighbors;
@property (nonatomic) BOOL done;
@property (nonatomic) NSInteger priorCol;
@property (nonatomic) NSInteger priorRow;
@property (nonatomic) ccColor4F toggleButtonColor;
@property (nonatomic) ccColor4F resetButtonColor;
@property (nonatomic, weak) CCLabelTTF *toggleLabel;
@property (nonatomic, strong) SimpleAudioEngine *audioEngine;
@end

@implementation GameOfLifeLayer

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
        NSLog(@"%d, %d", NUM_ROWS, NUM_COLS);
        self.audioEngine = [SimpleAudioEngine sharedEngine];
        NSLog(@"%@", self.audioEngine);
        [self.audioEngine preloadEffect:@"a-sound.WAV"];
        [self reset:NO];
        [self schedule:@selector(nextStep) interval:DELAY_IN_SECONDS];
        [self scheduleUpdate];
        CCLabelTTF *resetButton = [CCLabelTTF labelWithString:@"Reset" fontName:@"Helvetica" fontSize:FONT_SIZE];
        resetButton.position = CGPointMake(WIDTH_WINDOW / 4, HEIGHT_WINDOW - Y_OFF_SET);
        self.toggleLabel = [CCLabelTTF labelWithString:@"Running" fontName:@"Helvetica" fontSize:FONT_SIZE];
        self.toggleLabel.position = CGPointMake((WIDTH_WINDOW / 4) * 3, HEIGHT_WINDOW - Y_OFF_SET);
        [self addChild:resetButton];
        [self addChild:self.toggleLabel];
	}
	return self;
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

-(void)nextStep
{
    if(!self.done)
    {
        [self countNeighbors];
        [self updateGrid];
    }
}

-(void)reset:(BOOL)withColorChange
{
    self.gameGrid = nil;
    self.gameNeighbors = nil;
    self.priorCol = -1;
    self.priorRow = -1;
    self.toggleButtonColor = TOGGLE_BUTTON_COLOR_NORMAL;
    self.resetButtonColor = RESET_BUTTON_COLOR_NORMAL;
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

-(void)countNeighbors
{
    for(int row = 0; row < NUM_ROWS; row ++)
    {
        for(int col = 0; col < NUM_COLS; col ++)
        {
            //Must test all 8 cells
            NSUInteger numNeighbors =
                [self.gameGrid[[self previousRow:row]][col] unsignedIntValue] +
                [self.gameGrid[[self nextRow:row]][col] unsignedIntValue] +
                [self.gameGrid[row][[self previousCol:col]] unsignedIntValue] +
                [self.gameGrid[row][[self nextCol:col]] unsignedIntValue] +
                [self.gameGrid[[self previousRow:row]][[self previousCol:col]] unsignedIntValue] +
                [self.gameGrid[[self previousRow:row]][[self nextCol:col]] unsignedIntValue] +
                [self.gameGrid[[self nextRow:row]][[self previousCol:col]] unsignedIntValue] +
                [self.gameGrid[[self previousRow:row]][[self nextCol:col]] unsignedIntValue];
            self.gameNeighbors[row][col] = @(numNeighbors);
        }
    }
}

-(void)playSoundForRow:(NSUInteger)row col:(NSUInteger)col
{
    Float32 pitch = ((440.0f / NUM_COLS) * (col + 1)) / 440.0f; //Based on column
    Float32 gain = ((row + 1.0f) / (NUM_ROWS * 3)); //Based on row
    [self.audioEngine playEffect:@"a-sound.WAV" pitch:pitch pan:0 gain:gain];
}

-(void)updateGrid
{
    //Go through all the cells in gameNeighbors and change grid accordingly
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
            }
        }
    }
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
            NSUInteger cellValue = [self.gameGrid[row][col] unsignedIntValue];
            if(cellValue)
            {
                ccDrawSolidRect(CGPointMake(col * CELL_WIDTH, row * CELL_WIDTH),
                                CGPointMake((col + 1) * CELL_WIDTH, (row + 1) * CELL_WIDTH),
                                ccc4f(100.0/255.0, 0, 1.0, 1.0));
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
