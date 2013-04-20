//
//  SoundManager.h
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/12/13.
//
//

#import <Foundation/Foundation.h>
#import "SoundManager.h"

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

@interface AUSoundManager : SoundManager



@end
