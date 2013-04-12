//
//  OptionsLayer.h
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/12/13.
//
//

#import "CCLayer.h"

@protocol OptionsLayerDelegate <NSObject>

@end

@interface OptionsLayer : CCLayer

@property (nonatomic, strong) id<OptionsLayerDelegate> delegate;
@property (nonatomic, getter = isLayerCurrentlyVisible) BOOL layerCurrentlyVisible;

-(void)layerWillAppear;
-(void)layerWillDisappear;

@end
