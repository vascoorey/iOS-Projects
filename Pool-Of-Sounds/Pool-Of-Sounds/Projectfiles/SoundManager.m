//
//  SoundManager.m
//  Pool-Of-Sounds
//
//  Created by Vasco Orey on 4/20/13.
//
//

#import "SoundManager.h"

@implementation SoundManager

//Designated Initializer
-(id)initWithPatches:(NSInteger)numPatches
{
    NSAssert(false, @"Abstract method");
    return nil;
}
//Push an array of ints where 0 = don't play, 1 = play. Will convert the index of the object to a note.
-(void)pushRow:(NSArray *)row
{
    NSAssert(false, @"Abstract method");
}
//Same as pushRow: but will also change the intensity (i.e. volume)
-(void)pushRow:(NSArray *)row intensity:(float)intensity
{
    NSAssert(false, @"Abstract method");
}
//Plays the note for the given colum (i.e. array index)
-(void)playNoteForCol:(NSInteger)col
{
    NSAssert(false, @"Abstract method");
}
-(void)playNoteForCol:(NSInteger)col intensity:(float)intensity
{
    NSAssert(false, @"Abstract method");
}
//Stops playing all notes
-(void)stopPlaying
{
    NSAssert(false, @"Abstract method");
}

@end
