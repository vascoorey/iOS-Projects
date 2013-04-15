//
//  OptionsLayer.m
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/12/13.
//
//

#import "OptionsLayer.h"

@interface OptionsLayer ()
@property (nonatomic, strong) CCLabelTTF *tempoLabel;
@end

@implementation OptionsLayer

#warning TODO: options for tempo, scale, mode (music), game mode, grid size...

-(id)init
{
    if((self = [super init]))
    {
        self.tempoLabel = [CCLabelTTF labelWithString:@"Not Selected" fontName:@"Helvetica" fontSize:24.0f];
        CCMenu *menu = [CCMenu menuWithItems:
                        [CCMenuItemLabel itemWithLabel:self.tempoLabel block:^(id sender) {
            self.tempoLabel.string = @"Selected";
        }], nil];
        [self addChild:menu];
    }
    return self;
}

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
                    ccc4f(0, 0, 0, 0.25f));
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

+(CCScene *)scene
{
    CCScene *scene = [CCScene node];
    [scene addChild:[self node]];
    return scene;
}

@end
