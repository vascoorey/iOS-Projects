//
//  SetCard.h
//  Matchismo
//
//  Created by Vasco Orey on 2/14/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Card.h"

@interface SetCard : Card

@property (nonatomic, strong) NSString *shape;
@property (nonatomic) int shade;
@property (nonatomic) int color;
@property (nonatomic) int numShapes;

+(NSArray *)validShapes;
+(int)maxShade;
+(int)maxColor;
+(int)maxShapes;

@end
