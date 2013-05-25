//
//  Cells.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 5/24/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Life.h"

@interface Cells : Life

-(id)initWithRows:(NSInteger)rows cols:(NSInteger)cols seed:(NSUInteger)seed;
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started species:(NSInteger)species;

@end
