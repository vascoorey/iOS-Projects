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
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col active:(NSInteger)active;
@end

@interface PoolOfLife : NSObject

@property (nonatomic, strong) id <PoolOfLifeDelegate> delegate;
//Change this to regulate the food spawn probability (Evolutionary and Crazy mode)
@property (nonatomic) float foodSpawnProbability;

//Designated initializer
-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols gameMode:(kPoolOfLifeGameMode)gameMode;
-(void)reset;
-(void)nextStep;
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started;
-(NSInteger)cellAtRow:(NSInteger)row col:(NSInteger)col;
-(NSInteger)foodAtRow:(NSInteger)row col:(NSInteger)col;

@end
