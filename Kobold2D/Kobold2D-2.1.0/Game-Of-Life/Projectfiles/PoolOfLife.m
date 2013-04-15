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
@property (nonatomic) PoolOfLifeGameMode gameMode;
@property (nonatomic) NSInteger rows;
@property (nonatomic) NSInteger cols;
@property (nonatomic) NSInteger priorRow;
@property (nonatomic) NSInteger priorCol;
@property (nonatomic) NSInteger currentCycleStep;
@property (nonatomic) NSInteger lastRowIndex;
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

-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols gameMode:(PoolOfLifeGameMode)gameMode
{
    if((self = [super init]))
    {
        self.rows = rows;
        self.cols = cols;
        self.gameMode = gameMode;
        self.foodSpawnProbability = 0.05f;
        self.eatenFoodSpawnsNewCellsProbability = 0.33f;
        self.maxFood = 10;
        self.cycleSize = 9;
        self.lastRowIndex = 0;
    }
    return self;
}

-(void)reset
{
    self.grid = nil;
    self.neighbors = nil;
    self.priorCol = -1;
    self.priorRow = -1;
    self.foodCurrentlyActive = 0;
    for(int row = 0; row < self.rows; row ++)
    {
        NSMutableArray *line = [[NSMutableArray alloc] initWithCapacity:self.cols];
        NSMutableArray *foodLine = [[NSMutableArray alloc] initWithCapacity:self.cols];
        NSMutableArray *neighborsLine = [[NSMutableArray alloc] initWithCapacity:self.cols];
        for(int col = 0; col < self.cols; col ++)
        {
            foodLine[col] = @(0);
            line[col] = @(0);
            neighborsLine[col] = @(0);
        }
        self.grid[row] = line;
        self.neighbors[row] = neighborsLine;
        self.food[row] = foodLine;
    }
    if(self.gameMode == PoolOfLifeGameModeConwayWithFood || self.gameMode == PoolOfLifeGameModeCrazy)
    {
        [self seedRandomFood];
    }
}

-(void)seedRandomFood
{
    while(self.foodCurrentlyActive < self.maxFood)
    {
        [self plantSomeFood];
    }
}

-(void)plantSomeFood
{
    NSInteger row = arc4random() % self.rows;
    NSInteger col = arc4random() % self.cols;
    while([self.grid[row][col] intValue] || [self.food[row][col] intValue])
    {
        row = arc4random() % self.rows;
        col = arc4random() % self.cols;
    }
    self.food[row][col] = @(1);
    self.foodCurrentlyActive ++;
}

-(void)stepThroughCycle
{
    //Go through all the cells in gameNeighbors and change grid accordingly
    //1 row at a time
    self.cellsCurrentlyActive = 1;
    if(self.currentCycleStep >= self.cycleSize && self.lastRowIndex < (self.rows - 1))
    {
        [self stepThroughGrid:self.lastRowIndex toRow:self.rows];
    }
    else if(self.currentCycleStep >= self.cycleSize)
    {
        self.currentCycleStep = 0;
        self.lastRowIndex = 0;
        [self stepThroughGrid:self.lastRowIndex toRow:((1 + self.currentCycleStep) * (self.rows / self.cycleSize))];
    }
    else
    {
        [self stepThroughGrid:self.lastRowIndex toRow:((1 + self.currentCycleStep) * (self.rows / self.cycleSize))];
    }
    self.currentCycleStep ++;
}

-(void)stepThroughGrid:(NSInteger)fromRow toRow:(NSInteger)toRow
{
    self.cellsCurrentlyActive = 0;
    for(int row = fromRow; row < toRow; row ++)
    {
        self.lastRowIndex = row;
        if(self.gameMode != PoolOfLifeGameModeNone)
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
                    if([self.delegate respondsToSelector:@selector(didActivateCellAtRow:col:numActive:)])
                    {
                        [self.delegate didActivateCellAtRow:row col:col numActive:self.cellsCurrentlyActive];
                    }
                }
                if(self.gameMode == PoolOfLifeGameModeConwayWithFood || self.gameMode == PoolOfLifeGameModeCrazy)
                {
                    if([self.grid[row][col] intValue] && [self.food[row][col] intValue])
                    {
                        //A cell just ate some food! Reproduction?
                        [self cellAteFoodAtRow:row col:col];
                    }
                    else if(![self.food[row][col] intValue] && self.foodCurrentlyActive < self.maxFood)
                    {
                        //Spawn food according to food spawn percentage on empty cells
                        if(((arc4random() % 1000) + 1) / 1000.0f <= self.foodSpawnProbability)
                        {
                            [self plantSomeFood];
                        }
                    }
                }
            }
        }
        if([self.delegate respondsToSelector:@selector(didFinishUpdatingRowWithResultingRow:)])
        {
            [self.delegate didFinishUpdatingRowWithResultingRow:[self.grid[row] copy]];
        }
    }
}

-(void)cellAteFoodAtRow:(NSInteger)row col:(NSInteger)col
{
    NSInteger previousRow = [self previousRow:row];
    NSInteger nextRow = [self nextRow:row];
    NSInteger previousCol = [self previousCol:col];
    NSInteger nextCol = [self nextCol:col];
    self.food[row][col] = @(0);
    self.foodCurrentlyActive --;
    //Top-left
    if(((arc4random() % 100) + 1) / 100.0f <= self.eatenFoodSpawnsNewCellsProbability)
    {
        if(![self.grid[previousRow][previousCol] intValue])
        {
            self.grid[previousRow][previousCol] = @(1);
            [self updateNeighborsForRow:previousRow col:previousCol increment:YES];
        }
    }
    //Top
    if(((arc4random() % 100) + 1) / 100.0f <= self.eatenFoodSpawnsNewCellsProbability)
    {
        if(![self.grid[previousRow][col] intValue])
        {
            self.grid[previousRow][col] = @(1);
            [self updateNeighborsForRow:previousRow col:col increment:YES];
        }
    }
    //Top-right
    if(((arc4random() % 100) + 1) / 100.0f <= self.eatenFoodSpawnsNewCellsProbability)
    {
        if(![self.grid[previousRow][nextCol] intValue])
        {
            self.grid[previousRow][nextCol] = @(1);
            [self updateNeighborsForRow:previousRow col:nextCol increment:YES];
        }
    }
    //Left
    if(((arc4random() % 100) + 1) / 100.0f <= self.eatenFoodSpawnsNewCellsProbability)
    {
        if(![self.grid[row][previousCol] intValue])
        {
            self.grid[row][previousCol] = @(1);
            [self updateNeighborsForRow:row col:previousCol increment:YES];
        }
    }
    //Right
    if(((arc4random() % 100) + 1) / 100.0f <= self.eatenFoodSpawnsNewCellsProbability)
    {
        if(![self.grid[row][nextCol] intValue])
        {
            self.grid[row][nextCol] = @(1);
            [self updateNeighborsForRow:row col:nextCol increment:YES];
        }
    }
    //Bottom-left
    if(((arc4random() % 100) + 1) / 100.0f <= self.eatenFoodSpawnsNewCellsProbability)
    {
        if(![self.grid[nextRow][previousCol] intValue])
        {
            self.grid[nextRow][previousCol] = @(1);
            [self updateNeighborsForRow:nextRow col:previousCol increment:YES];
        }
    }
    //Bottom
    if(((arc4random() % 100) + 1) / 100.0f <= self.eatenFoodSpawnsNewCellsProbability)
    {
        if(![self.grid[nextRow][col] intValue])
        {
            self.grid[nextRow][col] = @(1);
            [self updateNeighborsForRow:nextRow col:col increment:YES];
        }
    }
    //Bottom-right
    if(((arc4random() % 100) + 1) / 100.0f <= self.eatenFoodSpawnsNewCellsProbability)
    {
        if(![self.grid[nextRow][nextCol] intValue])
        {
            self.grid[nextRow][nextCol] = @(1);
            [self updateNeighborsForRow:nextRow col:nextCol increment:YES];
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
        if([self.delegate respondsToSelector:@selector(didActivateCellAtRow:col:numActive:)])
        {
            [self.delegate didActivateCellAtRow:row col:col numActive:self.cellsCurrentlyActive];
        }
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
            if(self.gameMode == PoolOfLifeGameModeConwayWithFood || self.gameMode == PoolOfLifeGameModeCrazy)
            {
                if([self.food[row][col] intValue])
                {
                    [self cellAteFoodAtRow:row col:col];
                }
            }
        }
        self.priorRow = row;
        self.priorCol = col;
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
