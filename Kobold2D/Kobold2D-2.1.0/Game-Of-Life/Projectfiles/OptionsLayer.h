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
    kGameOfLifeOptionNone = 0,
    kGameOfLifeOptionScale,
    kGameOfLifeOptionMusicMode,
    kGameOfLifeOptionTempo,
    kGameOfLifeOptionPatch,
    kGameOfLifeOptionGridSize,
    kGameOfLifeOptionGameMode
} kGameOfLifeOption;

@protocol OptionsLayerDelegate <NSObject>
-(void)didFinishWithOptionsLayer;
-(void)didSetOption:(kGameOfLifeOption)option withValue:(id)value;
@end

@interface OptionsLayer : CCLayer

@property (nonatomic, strong) id<OptionsLayerDelegate> delegate;
@property (nonatomic, getter = isLayerCurrentlyVisible) BOOL layerCurrentlyVisible;

-(void)layerWillAppear;
-(void)layerWillDisappear;

@end
