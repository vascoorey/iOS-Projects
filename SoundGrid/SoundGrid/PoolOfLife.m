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

-(NSArray *)performStep
{
    NSArray *ret = nil;
    if(self.nextRowIndex % self.numRows == 0)
    {
        self.nextRowIndex = 0;
        [self updateGrid];
        ret = [self.grid copy];
    }
    if([self.delegate respondsToSelector:@selector(didFinishUpdatingRowWithResultingRow:)])
    {
        [self.delegate didFinishUpdatingRowWithResultingRow:[self.grid[self.nextRowIndex] copy]];
    }
    self.nextRowIndex ++;
    return ret;
}

-(NSInteger)updateDictionary:(NSMutableDictionary *)speciesForCell cell:(NSNumber *)cell species:(NSInteger)species
{
    if(self.numSpecies > 1)
    {
        if([[speciesForCell allKeys] containsObject:cell])
        {
            speciesForCell[cell] = @([speciesForCell[cell] intValue] + 1);
        }
        else
        {
            speciesForCell[cell] = @(1);
        }
    }
    return [cell intValue] == species;
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
            /*self.neighbors[row][col] =
            @([self.grid[previousRow][previousCol] intValue] +
            [self.grid[previousRow][col] intValue] +
            [self.grid[previousRow][nextCol] intValue] +
            [self.grid[row][previousCol] intValue] +
            [self.grid[row][nextCol] intValue] +
            [self.grid[nextRow][previousCol] intValue] +
            [self.grid[nextRow][col] intValue] +
            [self.grid[nextRow][nextCol] intValue]);
             */
            NSInteger species = [self.grid[row][col] intValue];
            NSInteger neighbors = 0;
            NSMutableDictionary *speciesForCell = [[NSMutableDictionary alloc] init];
            neighbors += [self updateDictionary:speciesForCell cell:self.grid[previousRow][previousCol] species:species];
            neighbors += [self updateDictionary:speciesForCell cell:self.grid[previousRow][col] species:species];
            neighbors += [self updateDictionary:speciesForCell cell:self.grid[previousRow][nextCol] species:species];
            neighbors += [self updateDictionary:speciesForCell cell:self.grid[row][previousCol] species:species];
            neighbors += [self updateDictionary:speciesForCell cell:self.grid[row][nextCol] species:species];
            neighbors += [self updateDictionary:speciesForCell cell:self.grid[nextRow][previousCol] species:species];
            neighbors += [self updateDictionary:speciesForCell cell:self.grid[nextRow][col] species:species];
            neighbors += [self updateDictionary:speciesForCell cell:self.grid[nextRow][nextCol] species:species];
            self.neighbors[row][col] = @(neighbors);
            if(self.numSpecies > 1)
            {
                NSArray *sorted = [speciesForCell keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    if ([obj1 integerValue] > [obj2 integerValue]) {
                        
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    if ([obj1 integerValue] < [obj2 integerValue]) {
                        
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                }];
                if(species) NSLog(@"Since %@ has %@ occurences, it's the dominant species for %d, %d", sorted[0], speciesForCell[sorted[0]], row, col);
                self.dominantSpecies[row][col] = sorted[0];
            }
        }
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
    if(started || self.priorRow != row || self.priorCol != col)
    {
        if([self.delegate respondsToSelector:@selector(didActivateCellAtRow:col:)])
        {
            [self.delegate didActivateCellAtRow:row col:col];
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

-(NSInteger)cellAtRow:(NSInteger)row col:(NSInteger)col
{
    return [self.grid[row][col] intValue];
}

@end
