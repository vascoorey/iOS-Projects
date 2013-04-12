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
    kPoolOfLifeGameModeNone = 0,
    //Regular Conway's Game Of Life
    kPoolOfLifeGameModeNormal,
    //Evolutionary Conway's Game Of Life. In addition to spawning at places with 3 neighbors will also spawn food that cells can "eat" and spawn aditional cells.
    kPoolOfLifeGameModeEvolutionary,
    kPoolOfLifeGameModeCrazy
} kPoolOfLifeGameMode;

@protocol PoolOfLifeDelegate <NSObject>
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col numActive:(NSInteger)numActive;
@end

@interface PoolOfLife : NSObject

@property (nonatomic, strong) id <PoolOfLifeDelegate> delegate;
//Change this to regulate the food spawn probability (Evolutionary and Crazy mode)
@property (nonatomic) float foodSpawnProbability;
//Change this to regulate how many steps to take per full cycle.
//EG: 1 = 1 step / cycle. 2 = 2 steps (half and half rows) etc... Think time signature.
@property (nonatomic) NSInteger cycleSize;

//Designated initializer
-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols gameMode:(kPoolOfLifeGameMode)gameMode;
-(void)reset;
-(void)stepThroughCycle;
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started;
-(NSInteger)cellAtRow:(NSInteger)row col:(NSInteger)col;
-(NSInteger)foodAtRow:(NSInteger)row col:(NSInteger)col;

@end
