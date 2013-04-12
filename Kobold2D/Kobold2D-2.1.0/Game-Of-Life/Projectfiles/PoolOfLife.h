//
//  LifePool.h
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/11/13.
//
//

#import <Foundation/Foundation.h>

@protocol PoolOfLifeDelegate <NSObject>
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col active:(NSInteger)active;
@end

@interface PoolOfLife : NSObject

@property (nonatomic, strong) id <PoolOfLifeDelegate> delegate;

//Designated initializer
-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols;
-(void)reset;
-(void)nextStep;
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started;
-(NSInteger)cellAtRow:(NSInteger)row col:(NSInteger)col;
-(NSInteger)foodAtRow:(NSInteger)row col:(NSInteger)col;

@end
