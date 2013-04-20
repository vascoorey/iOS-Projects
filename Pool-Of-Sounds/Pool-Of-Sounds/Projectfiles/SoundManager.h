//
//  SoundManager.h
//  Pool-Of-Sounds
//
//  Created by Vasco Orey on 4/20/13.
//
//

#import <Foundation/Foundation.h>

@interface SoundManager : NSObject

@property (nonatomic, getter = isPlaying) BOOL playing;
//Set this property to define the correct key for the grid
//Each time you set this property to a new value you will effectively reset the patches being played.
@property (nonatomic) NSInteger numPatches;

//Designated Initializer
-(id)initWithPatches:(NSInteger)numPatches;
//Push an array of ints where 0 = don't play, 1 = play. Will convert the index of the object to a note.
-(void)pushRow:(NSArray *)row;
//Same as pushRow: but will also change the intensity (i.e. volume)
-(void)pushRow:(NSArray *)row intensity:(float)intensity;
//Plays the note for the given colum (i.e. array index)
-(void)playNoteForCol:(NSInteger)col;
-(void)playNoteForCol:(NSInteger)col intensity:(float)intensity;
//Stops playing all notes
-(void)stopPlaying;

@end
