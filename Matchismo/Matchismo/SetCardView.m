//
//  SetCardView.m
//  Matchismo
//
//  Created by Vasco Orey on 2/19/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "SetCardView.h"

@implementation SetCardView

#define CORNER_RADIUS 12.0f

-(void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:CORNER_RADIUS];
    [roundedRect addClip];
    
    [[UIColor blackColor] setFill];
    UIRectFill(self.bounds);
    
    [[UIColor blueColor] setStroke];
    [roundedRect stroke];
}

#pragma mark Initialization

-(void)setup
{
    
}

-(void)awakeFromNib
{
    [self setup];
}

-(id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    return self;
}

@end
