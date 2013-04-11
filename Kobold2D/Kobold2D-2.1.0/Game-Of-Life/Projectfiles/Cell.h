//
//  Cell.h
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/11/13.
//
//

#import <Foundation/Foundation.h>

@interface Cell : NSObject

@property (nonatomic) NSInteger row;
@property (nonatomic) NSInteger col;
@property (nonatomic) NSInteger life;

+(Cell *)cellWithRow:(NSInteger)row col:(NSInteger)col;

@end
