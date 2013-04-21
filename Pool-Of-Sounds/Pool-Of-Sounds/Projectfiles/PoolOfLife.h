//
//  LifePool.h
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/11/13.
//
//

#import <Foundation/Foundation.h>

typedef enum
{
    //No reproduction. Will just report cells that the user has activated.
    PoolOfLifeGameModeNone = 0,
    //Regular Conway's Game Of Life
    PoolOfLifeGameModeConway,
    //In addition to spawning at places with 3 neighbors will also spawn food that cells can "eat" and spawn aditional cells.
    PoolOfLifeGameModeConwayWithFood,
    //Each active cell has some life and will randomly chose to move to an adjacent empty spot. It will look for food, which when "eaten" will spawn aditional cells.
    //Will spawn food and cells randomly.
    PoolOfLifeGameModeCrazy
} PoolOfLifeGameMode;

@protocol PoolOfLifeDelegate <NSObject>
@optional
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col;
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col species:(NSInteger)species;
-(void)didFinishUpdatingRowWithResultingRow:(NSArray *)row;
@end

@interface PoolOfLife : NSObject

@property (nonatomic, strong) id <PoolOfLifeDelegate> delegate;
//Change this to regulate the food spawn probability (Evolutionary and Crazy mode)
@property (nonatomic) float foodSpawnProbability;
//Each time a cell eats some food it will spawn cells around it using this probability.
@property (nonatomic) float eatenFoodSpawnsNewCellsProbability;
//Determines the maximum food available at any time
@property (nonatomic) NSInteger maxFood;
//Determines the number of species you can interact with
@property (nonatomic) NSInteger numSpecies;

//Designated initializer
-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols gameMode:(PoolOfLifeGameMode)gameMode;
-(void)reset;
//Returns index of current row being played
-(NSArray *)performStep;
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started;
//Use this method if you have set numSpecies > 1
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started species:(NSInteger)species;
-(NSInteger)cellAtRow:(NSInteger)row col:(NSInteger)col;
-(NSInteger)foodAtRow:(NSInteger)row col:(NSInteger)col;

@end
