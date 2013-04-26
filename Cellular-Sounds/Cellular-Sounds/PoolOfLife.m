//
//  LifePool.m
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/11/13.
//
//

#import "PoolOfLife.h"

@interface PoolOfLife ()
@property (nonatomic) PoolOfLifeGameMode gameMode;
@property (nonatomic) NSInteger numRows;
@property (nonatomic) NSInteger numCols;
@property (nonatomic) NSInteger priorRow;
@property (nonatomic) NSInteger priorCol;
@property (nonatomic) NSInteger currentCycleStep;
@property (nonatomic) NSInteger nextRowIndex;
@property (nonatomic) NSInteger foodCurrentlyActive;
@property (nonatomic, strong) NSMutableArray *grid;
@property (nonatomic, strong) NSMutableArray *neighbors;
@property (nonatomic, strong) NSMutableArray *dominantSpecies;
@end

@implementation PoolOfLife

-(NSMutableArray *)dominantSpecies
{
    if(!_dominantSpecies)
    {
        _dominantSpecies = [[NSMutableArray alloc] initWithCapacity:self.numRows];
    }
    return _dominantSpecies;
}

-(NSMutableArray *)grid
{
    if(!_grid)
    {
        _grid = [[NSMutableArray alloc] initWithCapacity:self.numRows];
    }
    return _grid;
}

-(NSMutableArray *)neighbors
{
    if(!_neighbors)
    {
        _neighbors = [[NSMutableArray alloc] initWithCapacity:self.numRows];
    }
    return _neighbors;
}

-(NSMutableArray *)state
{
    NSMutableArray *state = [[NSMutableArray alloc] initWithCapacity:self.numRows];
    for(NSArray *row in self.grid)
    {
        [state addObject:[row mutableCopy]];
    }
    return state;
}

#pragma mark -

-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols gameMode:(PoolOfLifeGameMode)gameMode
{
    if((self = [super init]))
    {
        self.numRows = rows;
        self.numCols = cols;
        self.gameMode = gameMode;
        self.nextRowIndex = 0;
        self.numSpecies = 1;
        [self reset];
    }
    return self;
}

-(void)reset
{
    self.grid = nil;
    self.neighbors = nil;
    self.priorCol = -1;
    self.priorRow = -1;
    self.nextRowIndex = 0;
    for(int row = 0; row < self.numRows; row ++)
    {
        NSMutableArray *line = [[NSMutableArray alloc] initWithCapacity:self.numCols];
        NSMutableArray *neighborsLine = [[NSMutableArray alloc] initWithCapacity:self.numCols];
        NSMutableArray *dominantSpeciesLine = [[NSMutableArray alloc] initWithCapacity:self.numCols];
        for(int col = 0; col < self.numCols; col ++)
        {
            line[col] = @(0);
            neighborsLine[col] = @(0);
            dominantSpeciesLine[col] = @(0);
        }
        self.grid[row] = line;
        self.neighbors[row] = neighborsLine;
        self.dominantSpecies[row] = dominantSpeciesLine;
    }
}

-(void)performStep
{
    [self updateGrid];
}

-(void)updateGrid
{
    //Update neighbors
    for(int row = 0; row < self.numRows; row ++)
    {
        for(int col = 0; col < self.numCols; col ++)
        {
            NSInteger previousRow = [self previousRow:row];
            NSInteger nextRow = [self nextRow:row];
            NSInteger previousCol = [self previousCol:col];
            NSInteger nextCol = [self nextCol:col];
            //Count neighbors
            self.neighbors[row][col] =
            @([self.grid[previousRow][previousCol] intValue] +
            [self.grid[previousRow][col] intValue] +
            [self.grid[previousRow][nextCol] intValue] +
            [self.grid[row][previousCol] intValue] +
            [self.grid[row][nextCol] intValue] +
            [self.grid[nextRow][previousCol] intValue] +
            [self.grid[nextRow][col] intValue] +
            [self.grid[nextRow][nextCol] intValue]);
            //Check dominant species
        }
#warning Todo: figure out dominant species for each cell
    }
    //Update grid
    for(int row = 0; row < self.numRows; row ++)
    {
        if(self.gameMode != PoolOfLifeGameModeNone)
        {
            for(int col = 0; col < self.numCols; col ++)
            {
                NSInteger numNeighbors = [self.neighbors[row][col] intValue];
                //Only update neighbors if theres an actual change to the board
                if(((numNeighbors < 2) || (numNeighbors > 3)) && [self.grid[row][col] intValue])
                {
                    //[self updateNeighborsForRow:row col:col increment:NO];
                    self.grid[row][col] = @(0);
                }
                else if(numNeighbors == 3 && ![self.grid[row][col] intValue])
                {
                    //[self updateNeighborsForRow:row col:col increment:YES];
                    self.grid[row][col] = @(1);
                    if([self.delegate respondsToSelector:@selector(didActivateCellAtRow:col:)])
                    {
                        [self.delegate didActivateCellAtRow:row col:col];
                    }
                }
            }
        }
    }
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

-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started
{
    [self flipCellAtRow:row col:col started:started species:1];
}

-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started species:(NSInteger)species
{
    NSLog(@"%d,%d %d -> %d", col, row, started, species);
    if(started || self.priorRow != row || self.priorCol != col)
    {
        if([self.delegate respondsToSelector:@selector(didActivateCellAtRow:col:species:)])
        {
            [self.delegate didActivateCellAtRow:row col:col species:species];
        }
        NSInteger previousValue = [self.grid[row][col] intValue];
        if(previousValue)
        {
            self.grid[row][col] = @(0);
        }
        else
        {
            self.grid[row][col] = @(species);
        }
        self.priorRow = row;
        self.priorCol = col;
    }
}

@end
