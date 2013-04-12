//
//  LifePool.m
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/11/13.
//
//

#import "PoolOfLife.h"
#import "Cell.h"

@interface PoolOfLife ()
@property (nonatomic) kPoolOfLifeGameMode gameMode;
@property (nonatomic) NSInteger rows;
@property (nonatomic) NSInteger cols;
@property (nonatomic) NSInteger priorRow;
@property (nonatomic) NSInteger priorCol;
@property (nonatomic) NSInteger foodCurrentlyActive;
@property (nonatomic) NSInteger cellsCurrentlyActive;
@property (nonatomic, strong) NSMutableArray *grid;
@property (nonatomic, strong) NSMutableArray *neighbors;
@property (nonatomic, strong) NSMutableArray *food;
@end

@implementation PoolOfLife

-(NSMutableArray *)food
{
    if(!_food)
    {
        _food = [[NSMutableArray alloc] initWithCapacity:self.rows];
    }
    return _food;
}

-(NSMutableArray *)grid
{
    if(!_grid)
    {
        _grid = [[NSMutableArray alloc] initWithCapacity:self.rows];
    }
    return _grid;
}

-(NSMutableArray *)neighbors
{
    if(!_neighbors)
    {
        _neighbors = [[NSMutableArray alloc] initWithCapacity:self.rows];
    }
    return _neighbors;
}

-(void)setFoodSpawnProbability:(float)foodSpawnProbability
{
    if(foodSpawnProbability > 1.0f)
    {
        _foodSpawnProbability = 1.0f;
    }
    else
    {
        _foodSpawnProbability = foodSpawnProbability;
    }
}

#pragma mark -

-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols gameMode:(kPoolOfLifeGameMode)gameMode
{
    if((self = [super init]))
    {
        self.rows = rows;
        self.cols = cols;
        self.gameMode = gameMode;
        self.foodSpawnProbability = 0.05f;
    }
    return self;
}

-(void)reset
{
    self.grid = nil;
    self.neighbors = nil;
    self.priorCol = -1;
    self.priorRow = -1;
    for(int row = 0; row < self.rows; row ++)
    {
        NSMutableArray *line = [[NSMutableArray alloc] initWithCapacity:self.rows];
        NSMutableArray *foodLine = [[NSMutableArray alloc] initWithCapacity:self.cols];
        for(int col = 0; col < self.cols; col ++)
        {
            foodLine[col] = @(0);
            if((arc4random() % 100) / 100.0f <= self.foodSpawnProbability)
            {
                self.foodCurrentlyActive ++;
                foodLine[col] = @(1);
            }
            line[col] = @(0);
        }
        self.grid[row] = line;
        self.neighbors[row] = [line mutableCopy];
        self.food[row] = foodLine;
    }
}

-(void)nextStep
{
    //CFTimeInterval old = CACurrentMediaTime();
    //[self countNeighbors];
    [self updateGrid];
    [self updateFood];
    //NSLog(@"Step time: %g", CACurrentMediaTime() - old);
}

-(void)updateFood
{
    //Check if any cell is on a food cell, if so activate its adjacent cells.
    //Spawned cells should not spawn new cells
    /*
    NSMutableArray *cellsToSpawn = [[NSMutableArray alloc] init];
    for(int row = 0; row < self.rows; row ++)
    {
        for(int col = 0; col < self.cols; col ++)
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
     */
}

//-(void)countNeighbors
//{
//    for(int row = 0; row < NUM_ROWS; row ++)
//    {
//        for(int col = 0; col < NUM_COLS; col ++)
//        {
//            //Must test all 8 cells
//            NSUInteger numNeighbors =
//            [self.gameGrid[[self previousRow:row]][col] intValue] +
//            [self.gameGrid[[self nextRow:row]][col] intValue] +
//            [self.gameGrid[row][[self previousCol:col]] intValue] +
//            [self.gameGrid[row][[self nextCol:col]] intValue] +
//            [self.gameGrid[[self previousRow:row]][[self previousCol:col]] intValue] +
//            [self.gameGrid[[self previousRow:row]][[self nextCol:col]] intValue] +
//            [self.gameGrid[[self nextRow:row]][[self previousCol:col]] intValue] +
//            [self.gameGrid[[self previousRow:row]][[self nextCol:col]] intValue];
//            self.gameNeighbors[row][col] = @(numNeighbors);
//        }
//    }
//}

-(void)updateGrid
{
    //Go through all the cells in gameNeighbors and change grid accordingly
    self.cellsCurrentlyActive = 1;
    for(int row = 0; row < self.rows; row ++)
    {
        for(int col = 0; col < self.cols; col ++)
        {
            NSUInteger numNeighbors = [self.neighbors[row][col] unsignedIntValue];
            if(((numNeighbors <= 1) || (numNeighbors >= 4)) && [self.grid[row][col] intValue])
            {
                //Only update neighbors if theres an actual change to the board
                [self updateNeighborsForRow:row col:col increment:NO];
                self.grid[row][col] = @(0);
            }
            else if(numNeighbors == 3 && ![self.grid[row][col] intValue])
            {
                //Ditto
                [self updateNeighborsForRow:row col:col increment:YES];
                self.grid[row][col] = @(1);
                self.cellsCurrentlyActive ++;
                [self.delegate didActivateCellAtRow:row col:col active:self.cellsCurrentlyActive];
            }
        }
    }
}

-(void)updateNeighborsForRow:(NSInteger)row col:(NSInteger)col increment:(BOOL)increment
{
    NSInteger previousRow = [self previousRow:row];
    NSInteger nextRow = [self nextRow:row];
    NSInteger previousCol = [self previousCol:col];
    NSInteger nextCol = [self nextCol:col];
    //Top
    self.neighbors[previousRow][previousCol] = @([self.neighbors[previousRow][previousCol] intValue] + (increment ? 1 : -1));
    self.neighbors[previousRow][col] = @([self.neighbors[previousRow][col] intValue] + (increment ? 1 : -1));
    self.neighbors[previousRow][nextCol] = @([self.neighbors[previousRow][nextCol] intValue] + (increment ? 1 : -1));
    //Middle
    self.neighbors[row][previousCol] = @([self.neighbors[row][previousCol] intValue] + (increment ? 1 : -1));
    self.neighbors[row][nextCol] = @([self.neighbors[row][nextCol] intValue] + (increment ? 1 : -1));
    //Bottom
    self.neighbors[nextRow][previousCol] = @([self.neighbors[nextRow][previousCol] intValue] + (increment ? 1 : -1));
    self.neighbors[nextRow][col] = @([self.neighbors[nextRow][col] intValue] + (increment ? 1 : -1));
    self.neighbors[nextRow][nextCol] = @([self.neighbors[nextRow][nextCol] intValue] + (increment ? 1 : -1));
}

-(NSUInteger)previousRow:(NSUInteger)row
{
    //Wrap around if row == 0
    return (row - 1) % self.rows;
}

-(NSUInteger)previousCol:(NSUInteger)col
{
    return (col - 1) % self.cols;
}

-(NSUInteger)nextRow:(NSUInteger)row
{
    return (row + 1) % self.rows;
}

-(NSUInteger)nextCol:(NSUInteger)col
{
    return (col + 1) % self.cols;
}

-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started
{
    if(started || self.priorRow != row || self.priorCol != col)
    {
        [self.delegate didActivateCellAtRow:row col:col active:self.cellsCurrentlyActive];
        NSUInteger previousValue = [self.grid[row][col] unsignedIntValue];
        if(previousValue)
        {
            self.grid[row][col] = @(0);
            [self updateNeighborsForRow:row col:col increment:NO];
        }
        else
        {
            self.grid[row][col] = @(1);
            [self updateNeighborsForRow:row col:col increment:YES];
        }
        self.priorCol = col;
        self.priorRow = row;
    }
}

-(NSInteger)cellAtRow:(NSInteger)row col:(NSInteger)col
{
    return [self.grid[row][col] intValue];
}

-(NSInteger)foodAtRow:(NSInteger)row col:(NSInteger)col
{
    return [self.food[row][col] intValue];
}

@end
