//
//  LifePool.h
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/11/13.
//
//

#import "Life.h"

typedef enum
{
    //No reproduction. Will just report cells that the user has activated.
    PoolOfLifeGameModeNone = 0,
    //Regular Conway's Game Of Life
    PoolOfLifeGameModeConway,
} PoolOfLifeGameMode;

@interface PoolOfLife : Life

@property (nonatomic) PoolOfLifeGameMode gameMode;

//Designated initializer
-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols gameMode:(PoolOfLifeGameMode)gameMode;

@end
