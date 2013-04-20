//
//  PDSoundManager.m
//  Pool-Of-Sounds
//
//  Created by Vasco Orey on 4/17/13.
//
//

#import "PDSoundManager.h"
#import <QuartzCore/QuartzCore.h>

#import "PdBase.h"
#import "PdFile.h"
#import "PdAudioController.h"
#import "PdDispatcher.h"

typedef enum {
	kMIDIMessage_NoteOn    = 0x9,
	kMIDIMessage_NoteOff   = 0x8,
} kMIDIMessage;

@interface PDSoundManager () <PdListener>
@property (nonatomic, strong) NSMutableArray *notesBeingPlayed;
@property (nonatomic, strong) NSMutableArray *patches;
@property (nonatomic, strong) PdAudioController *audioController;
@property (nonatomic, strong) PdDispatcher *dispatcher;
@property (nonatomic, strong) PdFile *patch;
@property (nonatomic) NSInteger root;
@property (nonatomic) NSInteger scale;
@property (nonatomic) NSInteger tuning;
@property (nonatomic) NSInteger octave;
@end

@implementation PDSoundManager

-(NSMutableArray *)notesBeingPlayed
{
    if(!_notesBeingPlayed)
    {
        _notesBeingPlayed = [[NSMutableArray alloc] init];
    }
    return _notesBeingPlayed;
}

-(id)initWithPatches:(NSInteger)numPatches
{
    if((self = [super init]))
    {
        self.root = 0;
        self.scale = 0;
        self.tuning = 43;
        self.octave = 0;
        
        /* Audio Controller setup code */
        self.audioController = [[PdAudioController alloc] init];
        
        if ([self.audioController configureAmbientWithSampleRate:44100
                                                  numberChannels:2 mixingEnabled:YES] != PdAudioOK) {
            NSLog(@"failed to initialize audio components");
        }
        self.audioController.active = YES;
        NSLog(@"AudioController: %@ -> %d", self.audioController, self.audioController.active);
        
        /* Initializing the dispatcher with the patch */
        PdDispatcher *dispatcher = [[PdDispatcher alloc] init];
        [PdBase setDelegate:dispatcher];
        
        //added first iteration of new synth 28/03/12
        self.patch = [PdFile openFileNamed:@"chipwave.pd" path:[[NSBundle mainBundle] resourcePath]];
//        for(int i = 0; i < numPatches; i++)
//        {
//            PdFile *patch = [PdFile openFileNamed:@"MMM5_Poly.pd"
//                        path:[[NSBundle mainBundle] resourcePath]];
//            _patches[i] = patch;
//            if (!patch) {
//                NSLog(@"Failed to open patch!");
//                // Gracefully handle failure...
//            }
//        }
    }
    return self;
}

-(void)dealloc
{
    [self.patch closeFile];
    [PdBase setDelegate:nil];
}

/* Updates the MIDI note information in the dispatcher */
-(void) stopNote:(int)n
{
    //[PdBase sendFloat:n toReceiver:@"midinote"];
    //[PdBase sendNoteOn:0 pitch:[self convertToMidi:n] velocity:0];
    //NSLog(@"Stopping %d", n);
    //[PdBase sendControlChange:0 controller:[self convertToMidi:n] value:0];
    [PdBase sendNoteOn:128 pitch:[self convertToMidi:n] velocity:0];
    [PdBase sendNoteOn:129 pitch:[self convertToMidi:n] velocity:0];
    [PdBase sendNoteOn:130 pitch:[self convertToMidi:n] velocity:0];
    [PdBase sendNoteOn:131 pitch:[self convertToMidi:n] velocity:0];
}

/* Sends a MIDI note and a trigger to our dispatcher */
-(void) playNote:(int)n velocity:(int)velocity
{
    //NSLog(@"Playing %d", n);
    //NSLog(@"%d", [PdBase sendFloat:n toReceiver:@"notein"]);
    //[PdBase sendBangToReceiver:@"trigger"];
    [PdBase sendNoteOn:144 pitch:[self convertToMidi:n] velocity:velocity];
    [PdBase sendNoteOn:145 pitch:[self convertToMidi:n] velocity:velocity];
    [PdBase sendNoteOn:146 pitch:[self convertToMidi:n] velocity:velocity];
    [PdBase sendNoteOn:147 pitch:[self convertToMidi:n] velocity:velocity];
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

-(void)pushRow:(NSArray *)row
{
    [self pushRow:row intensity:1.0f];
}

-(void)pushRow:(NSArray *)row intensity:(float)intensity
{
    for(int col = 0; col < (int)[row count]; col ++)
    {
        int colValue = [row[col] intValue];
        BOOL playingNote = [self isPlayingNote:col];
        if(colValue && !playingNote)
        {
            [self.notesBeingPlayed addObject:@(col)];
            [self playNoteForCol:col intensity:intensity];
        }
        else if(playingNote)
        {
            [self.notesBeingPlayed removeObject:@(col)];
            [self stopNote:col];
        }
    }
}

-(void)playNoteForCol:(NSInteger)col
{
    [self playNoteForCol:col intensity:1.0f];
}

-(void)playNoteForCol:(NSInteger)col intensity:(float)intensity
{
    if(intensity > 1.0f)
    {
        intensity = 1.0f;
    }
    if(intensity < 0.0f)
    {
        intensity = 0.0f;
    }
    [self playNote:col velocity:(127 * intensity)];
}

-(void)stopPlaying
{
    NSArray *notes = [self.notesBeingPlayed copy];
    for(NSNumber *note in notes)
    {
        [self stopNote:[note intValue]];
    }
}

-(BOOL)isPlayingNote:(int)note
{
    return [self.notesBeingPlayed containsObject:@(note)];
}

@end