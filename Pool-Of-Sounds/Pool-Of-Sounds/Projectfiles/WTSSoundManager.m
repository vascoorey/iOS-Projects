//
//  WTSSoundManager.m
//  Pool-Of-Sounds
//
//  Created by Vasco Orey on 4/20/13.
//
//

#import "WTSSoundManager.h"
#import "AQSound.h"

@interface WTSSoundManager ()
@property (nonatomic, strong) AQSound *sound;
@property (nonatomic, strong) NSMutableArray *voicesPlaying;
@end

@implementation WTSSoundManager

-(NSMutableArray *)voicesPlaying
{
    if(!_voicesPlaying)
    {
        _voicesPlaying = [[NSMutableArray alloc] initWithCapacity:kNumberVoices];
        for(int i = 0; i < kNumberVoices; i ++)
        {
            _voicesPlaying[i] = @(0);
        }
    }
    return _voicesPlaying;
}

//Designated Initializer
-(id)initWithPatches:(NSInteger)numPatches
{
    if((self = [super init]))
    {
        self.numPatches = numPatches;
        self.sound = [[AQSound alloc] init];
        [self.sound start];
        self.sound.soundType = Strings;
    }
    return self;
}

//Push an array of ints where 0 = don't play, 1 = play. Will convert the index of the object to a note.
-(void)pushRow:(NSArray *)row
{
    [self pushRow:row intensity:1.0f];
}
//Same as pushRow: but will also change the intensity (i.e. volume)
-(void)pushRow:(NSArray *)row intensity:(float)intensity
{
    for(int i = 0; i < (int)[row count]; i ++)
    {
        int midiNote = [self convertToMidi:i];
        BOOL playing = [self.voicesPlaying containsObject:@(midiNote)];
        if([row[i] intValue] && !playing)
        {
            //Start playing
            [self startPlayingNote:midiNote];
        }
        else if(![row[i] intValue] && playing)
        {
            //Stop playing
            [self stopPlayingNote:midiNote];
        }
    }
}
//Plays the note for the given colum (i.e. array index)
-(void)playNoteForCol:(NSInteger)col
{
    [self playNoteForCol:col intensity:1.0f];
}
-(void)playNoteForCol:(NSInteger)col intensity:(float)intensity
{
    int midiNote = [self convertToMidi:col];
    [self startPlayingNote:midiNote];
    
}
//Stops playing all notes
-(void)stopPlaying
{
    NSArray *notesPlaying = [self.voicesPlaying copy];
    for(NSNumber *note in notesPlaying)
    {
        [self stopPlayingNote:[note intValue]];
    }
}

-(void)startPlayingNote:(int)note
{
    for(int i = 0; i < (int)[self.voicesPlaying count]; i ++)
    {
        if(![self.voicesPlaying[i] intValue])
        {
            NSAssert(i < kNumberVoices, @"Too many notes on!");
            NSLog(@"Playing: %d", note);
            //First available voice: play
            self.voicesPlaying[i] = @(note);
            [self.sound midiNoteOn:note atVoiceIndex:i];
            return;
        }
    }
}

//Stops note
-(void)stopPlayingNote:(int)note
{
    int voice = [self.voicesPlaying indexOfObject:@(note)];
    self.voicesPlaying[voice] = @(0);
    [self.sound midiNoteOff:note atVoiceIndex:voice];
    NSLog(@"Stopping: %d", note);
}

//C3 = 36, D = 38, E = 40, F = 41, G = 43, A = 45, B = 47
#define C_MAJ_NOTES @[@(36), @(38), @(40), @(41), @(43), @(45), @(47)]
//C D E G A C
#define C_PENT_MAJ_NOTES @[@(24), @(26), @(28), @(31), @(33), @(36)]
//A C D E G A
#define A_PENT_MIN_NOTES @[@(21), @(24), @(26), @(28), @(31), @(33)]
//Arpeggios
//C - E - G, D - F - A, E - G - B
#define C_MAJ_ARPEGGIOS @[@(24), @(28), @(31), /**/ @(26), @(29), @(33), /**/ @(28), @(31), @(35)]

// http://www.midimountain.com/midi/midi_note_numbers.html
-(int)convertToMidi:(int)note
{
    NSInteger count = [C_MAJ_NOTES count];
    int midiNote = [[C_MAJ_NOTES objectAtIndex:(note % count)] intValue] + (12 * (note / count));
    return midiNote;
}

@end
