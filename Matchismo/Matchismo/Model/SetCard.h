//
//  SetCard.h
//  Matchismo
//
//  Created by Vasco Orey on 2/14/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Card.h"

@interface SetCard : Card

@property (nonatomic) int shape;
@property (nonatomic) int shade;
@property (nonatomic) int color;
@property (nonatomic) int numShapes;
@property (nonatomic, readonly) float shadeValue;

+(int)numberOfShapes;
+(int)maxShade;
+(int)maxColor;
+(int)maxShapes;

@end
