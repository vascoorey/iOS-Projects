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
} PoolOfLifeGameMode;

@protocol PoolOfLifeDelegate <NSObject>
@optional
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col;
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col species:(NSInteger)species;
-(void)didFinishUpdatingRowWithResultingRow:(NSArray *)row;
@end

@interface PoolOfLife : NSObject

@property (nonatomic, strong) id <PoolOfLifeDelegate> delegate;
//Determines the number of species you can interact with
@property (nonatomic) NSInteger numSpecies;
//Get the current state
@property (nonatomic, readonly) NSArray *state;

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
