//
//  OptionsLayer.m
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/12/13.
//
//

#import "OptionsLayer.h"

@implementation OptionsLayer

#pragma mark todo - maybe with sprites or some such

-(void)layerWillAppear
{
    [self scheduleUpdate];
    self.layerCurrentlyVisible = YES;
}

-(void)layerWillDisappear
{
    [self unscheduleUpdate];
    self.layerCurrentlyVisible = NO;
}

-(void)draw
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    ccDrawSolidRect(CGPointMake(0, 0),
                    CGPointMake(winSize.width, winSize.height),
                    ccc4f(0, 1, 1, 1));
}

-(void)update:(ccTime)delta
{
    //React to touch input
    KKInput *input = [KKInput sharedInput];
    if(input.touchesAvailable)
    {
        KKTouch *touch;
        CCARRAY_FOREACH(input.touches, touch)
        {
            if([input isAnyTouchOnNode:self touchPhase:KKTouchPhaseBegan])
            {
                [self.delegate didFinishWithOptionsLayer];
            }
        }
    }
}

@end
