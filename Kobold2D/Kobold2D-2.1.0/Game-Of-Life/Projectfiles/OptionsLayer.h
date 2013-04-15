//
//  OptionsLayer.h
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/12/13.
//
//

#import "CCLayer.h"

typedef enum
{
    PoolOfLifeOptionNone = 0,
    PoolOfLifeOptionScale,
    PoolOfLifeOptionMusicMode,
    PoolOfLifeOptionTempo,
    PoolOfLifeOptionPatch,
    PoolOfLifeOptionGridSize,
    PoolOfLifeOptionGameMode
} PoolOfLifeOption;

@protocol OptionsLayerDelegate <NSObject>
-(void)didFinishWithOptionsLayer;
-(void)didSetOption:(PoolOfLifeOption)option withValue:(id)value;
@end

@interface OptionsLayer : CCLayer

@property (nonatomic, strong) id<OptionsLayerDelegate> delegate;
@property (nonatomic, getter = isLayerCurrentlyVisible) BOOL layerCurrentlyVisible;

-(void)layerWillAppear;
-(void)layerWillDisappear;

+(CCScene *)scene;

@end
