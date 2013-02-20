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
#define Y_OFFSET 0.05f
#define X_OFFSET 0.1f
#define RECT_SIZE 0.3f

-(void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:CORNER_RADIUS];
    [roundedRect addClip];
    
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    
    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
}

-(void)drawDiamondAtPoint:(CGPoint)point
{
    UIBezierPath *diamond = [UIBezierPath bezierPath];
    [diamond moveToPoint:point];
}

-(void)drawSquiglyAtPoint:(CGPoint)point
{
    
}

-(void)drawOvalAtPoint:(CGPoint)point
{
    
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
