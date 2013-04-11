//
//  LifePool.h
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/11/13.
//
//

#import <Foundation/Foundation.h>

@protocol LifePoolDelegate <NSObject>

-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col;

@end

@interface LifePool : NSObject

@property (nonatomic, strong) id <LifePoolDelegate> delegate;

@end
