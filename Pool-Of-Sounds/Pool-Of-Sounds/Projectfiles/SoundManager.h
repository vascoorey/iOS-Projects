//
//  SoundManager.h
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/12/13.
//
//

#import <Foundation/Foundation.h>

typedef enum
{
    kSoundManagerScaleNone = -1,
    kSoundManagerScaleIonian,
    kSoundManagerScaleAeolian,
    kSoundManagerScaleLocrian,
    kSoundManagerScaleDorian,
    kSoundManagerScalePhrygian,
    kSoundManagerScaleLydian,
    kSoundManagerScaleMixolydian
} kSoundManagerScale;

@interface SoundManager : NSObject

@property (nonatomic) kSoundManagerScale scale;
@property (nonatomic, getter = isPlaying) BOOL playing;
//Set this property to define the correct key for the grid
@property (nonatomic) NSInteger numCols;

//Designated Initializer
-(id)initWithScale:(kSoundManagerScale)scale;
-(void)pushRow:(NSArray *)row;
-(void)pushRow:(NSArray *)row intensity:(float)intensity;
-(void)playNoteForCol:(NSInteger)col;
-(void)playNoteForCol:(NSInteger)col intensity:(float)intensity;
-(void)stopPlaying;

@end
