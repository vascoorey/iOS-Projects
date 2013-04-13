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
    kSoundManagerScaleNone = 0,
    kSoundManagerScaleAeolian,
    kSoundManagerScaleLocrian,
    kSoundManagerScaleIonian,
    kSoundManagerScaleDorian,
    kSoundManagerScalePhrygian,
    kSoundManagerScaleLydian,
    kSoundManagerScaleMixolydian
} kSoundManagerScale;

@interface SoundManager : NSObject

@property (nonatomic) kSoundManagerScale scale;

-(void)pushNoteAtRow:(NSInteger)row col:(NSInteger)col;
-(void)play;

@end
