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
} PoolOfLifeGameMode;

@protocol PoolOfLifeDelegate <NSObject>
@optional
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col;
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col species:(NSInteger)species;
@end

@interface PoolOfLife : NSObject

@property (nonatomic, strong) id <PoolOfLifeDelegate> delegate;
//Get the current state
@property (nonatomic, readonly) NSMutableArray *state;
@property (nonatomic) PoolOfLifeGameMode gameMode;

//Designated initializer
-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols gameMode:(PoolOfLifeGameMode)gameMode;
-(void)reset;
-(void)performStep;
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started;
//Use this method if you have set numSpecies > 1
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started species:(NSInteger)species;

@end
