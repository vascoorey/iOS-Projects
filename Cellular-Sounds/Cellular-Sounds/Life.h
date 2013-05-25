//
//  Life.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 5/24/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LifeDelegate <NSObject>
@optional
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col;
-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col species:(NSInteger)species;
@end

@interface Life : NSObject

//Get the current state
@property (nonatomic, readonly) NSMutableArray *state;
@property (nonatomic, strong) id <LifeDelegate> delegate;
@property (nonatomic) NSInteger numRows;
@property (nonatomic) NSInteger numCols;

//Provided
-(NSInteger)previousRow:(NSInteger)row;
-(NSInteger)nextRow:(NSInteger)row;
-(NSInteger)previousCol:(NSInteger)col;
-(NSInteger)nextCol:(NSInteger)col;
//Abstract
-(void)reset;
-(void)performStep;
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started;
//@requires species >= 0
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started species:(NSInteger)species;

@end
