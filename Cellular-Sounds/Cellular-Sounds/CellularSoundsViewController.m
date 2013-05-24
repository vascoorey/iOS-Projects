//
//  CellularSoundsViewController.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 4/23/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CellularSoundsViewController.h"
#import "GridView.h"
#import "PoolOfLife.h"
#import "OptionsViewController.h"
//MIDI
#import "BMidiManager.h"
#import "BSequence.h"
#import "BNoteEventHandler.h"
#import "BSequencePlayer.h"
#import "BMidiClock.h"
#import "AudioManager.h"
#import "BMidiNote.h"
//WTS
#import "AQSound.h"
//Notes
#import "NoteDefs.h"

@interface CellularSoundsViewController () <GridViewDelegate, PoolOfLifeDelegate, OptionsDelegate>
//Outlets
@property (weak, nonatomic) IBOutlet UILabel *metronomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSpeciesLabel;
@property (weak, nonatomic) IBOutlet UIButton *poolModeButton;
@property (weak, nonatomic) IBOutlet GridView *gridView;
//MIDI
@property (nonatomic, strong) BSequencePlayer *sequencePlayer;
@property (nonatomic, strong) BMidiClock *midiClock;
@property (nonatomic, strong) AudioManager *audioManager;
@property (nonatomic) NSUInteger metronomeTicks;
@property (nonatomic) CFTimeInterval timeOfLastBeat;
//Access this property using @synchronized(self.sequence) as it's being used
@property (nonatomic, strong) NSMutableArray *sequence;
@property (nonatomic, strong) NSMutableArray *completeSong;
@property (nonatomic) NSInteger timeForNextUpdate;
@property (nonatomic) NSInteger startTimeForNextBar;
@property (nonatomic) NSInteger lineDeltaTime;
//Model
@property (nonatomic) NSInteger numPools;
@property (nonatomic) NSInteger currentPool;
@property (nonatomic, strong) NSArray *pools;
@property (nonatomic, readonly) PoolOfLife *pool;
@property (nonatomic) NSInteger numRows;
@property (nonatomic) NSInteger numCols;
@property (nonatomic) PoolOfLifeGameMode gameMode;
@property (nonatomic) NSInteger currentSpecies;
@property (nonatomic) NSInteger updateTime;
//Control
@property (nonatomic, getter = isPlaying) BOOL playing;
//Note defs
@property (nonatomic) NSInteger rootNote;
@property (nonatomic, strong) NSString *scale;
@end

@implementation CellularSoundsViewController

#pragma mark - Properties - Lazy Instantiation

-(PoolOfLife *)pool
{
    return [self.pools count] ? self.pools[self.currentPool] : nil;
}

-(void)setNumPools:(NSInteger)numPools
{
    if(numPools > 0 && numPools != _numPools)
    {
        _numPools = numPools;
        for(PoolOfLife *pool in _pools)
        {
            pool.delegate = nil;
        }
        _pools = nil;
    }
}

-(NSArray *)pools
{
    if(!_pools)
    {
        NSMutableArray *allPools = [NSMutableArray array];
        for(int i = 0; i < self.numPools; i ++)
        {
            PoolOfLife *newPool = [[PoolOfLife alloc] initWithRows:self.numRows cols:self.numCols gameMode:PoolOfLifeGameModeConway];
            newPool.delegate = self;
            [allPools addObject:newPool];
        }
        _pools = allPools;
    }
    return _pools;
}

-(NSMutableArray *)completeSong
{
    if(!_completeSong)
    {
        _completeSong = [[NSMutableArray alloc] init];
    }
    return _completeSong;
}

#pragma mark - View Lifecycle

-(void)setup
{
    //Perform setup that has to go before viewDidLoad
    self.numCols = 21;
    self.numRows = 16;
    self.currentSpecies = 1;
    self.gameMode = PoolOfLifeGameModeConway;
    self.numPools = 4;
    self.playing = YES;
    [self setupSound];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)awakeFromNib
{
    [self setup];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.gridView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.gridView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GridView Delegate

-(void)didDetectTouchAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started
{
    //NSLog(@"%d,%d, %d", col, row, started);
    [self.pool flipCellAtRow:row col:col started:started species:self.currentSpecies];
}

#pragma mark - PoolOfLife Delegate

-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col species:(NSInteger)species
{
    [self.gridView activateRow:row col:col color:species];
}

#pragma mark - Options Delegate

-(void)setVolume:(float)volume forVoice:(NSInteger)voice
{
    [self.audioManager setVolume:volume forChannel:voice];
}

-(float)volumeForVoice:(NSInteger)voice
{
    return [self.audioManager volumeForChannel:voice];
}

-(float)panForVoice:(NSInteger)voice
{
    return [self.audioManager panForChannel:voice];
}

-(void)setPan:(float)pan forVoice:(NSInteger)voice
{
    [self.audioManager setPan:pan forChannel:voice];
}

-(void)killAudio
{
    [self.audioManager stopAudioGraph];
}

-(void)startAudio
{
    [self.audioManager restartAudioGraph];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Options Segue"])
    {
        OptionsViewController *optionsVC = (OptionsViewController *)segue.destinationViewController;
        optionsVC.delegate = self;
        optionsVC.currentVoice = self.currentSpecies - 1;
    }
}

#pragma mark - IBActions

- (IBAction)startStop:(UIButton *)sender
{
    if(!self.isPlaying)
    {
        [self.midiClock resume];
        [self.audioManager setVolume:1];
        [sender setTitle:@"Pause" forState:UIControlStateNormal];
        self.playing = YES;
    }
    else
    {
        self.playing = NO;
        [self.midiClock pause];
        [self.audioManager setVolume:0];
        [sender setTitle:@"Resume" forState:UIControlStateNormal];
    }
}

- (IBAction)reset
{
    [self.pools makeObjectsPerformSelector:@selector(reset)];
    self.gridView.grid = self.pool.state;
    @synchronized(self.sequence)
    {
        [self.sequence removeAllObjects];
    }
}

- (IBAction)changeCurrentSpecies:(UIButton *)sender
{
    self.currentSpecies = sender.tag;
    NSString *text;
    switch (sender.tag)
    {
        case 1:
            text = @"Blue";
            break;
        case 2:
            text = @"Green";
            break;
        case 3:
            text = @"Yellow";
            break;
        case 4:
            text = @"Red";
            break;
        default:
            break;
    }
    self.currentSpeciesLabel.text = text;
    self.currentSpeciesLabel.textColor = sender.backgroundColor;
}

- (IBAction)changeCurrentPool:(UISegmentedControl *)sender {
    self.currentPool = sender.selectedSegmentIndex;
    self.gridView.grid = self.pool.state;
}

- (IBAction)poolModeButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.pool.gameMode = sender.selected ? PoolOfLifeGameModeNone : PoolOfLifeGameModeConway;
}

#pragma mark - Unwind Segue

-(IBAction)doneSettingOptions:(UIStoryboardSegue *)segue
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - MIDI-Library

// What to do when a new note is activated - be very careful!! We're
// multi-threading
-(void) handleNoteEvent:(BMidiNote *)note
{
    // Play the note in the audio manager
    [self.audioManager playNote:note];
    //NSLog(@"Note: %d, Channel: %d, Velocity: %d, Start: %d, Duration: %d", note.note, note.channel, note.velocity, [note getStartTime], [note getDuration]);
    //[self.sound triggerMidiNoteAtFirstAvailableVoice:note.note velocity:127];
}

// Handle any tempo events which occur
-(void) handleTempoEvent:(BTempoEvent *)tempoEvent
{
    // Set the midi clock PPNQ
    if(tempoEvent.type == BPPNQ) {
        self.midiClock.PPQN = tempoEvent.PPNQ;
        NSLog(@"Set PPQN: %i", tempoEvent.PPNQ);
    }
    // Set the midi clock BPM
    if (tempoEvent.type == BTempo) {
        self.midiClock.BPM = tempoEvent.BPM;
        NSLog(@"Set BPM: %f", tempoEvent.BPM);
    }
    
    // Set the metronome rate
    if (tempoEvent.type == BTimeSignature) {
        // Set metronome rate. The metronome figure is measured as a fraction
        // over 24. So, a value of 24 means once per quarter note. 12 means
        // once every 1/8 note etc...
        float metronomeRate = (float) tempoEvent.ticksPerQtr / 24.0;
        // Work out how many pulses this represents
        self.midiClock.metronomeFreq = (int) roundf(metronomeRate * self.midiClock.PPQN);
        
    }
}

-(void) setupSound
{
    // Create a new midi clock - this keeps track of MIDI time based on
    // midi properties such as BPM
    self.midiClock = [BMidiClock new];
    self.midiClock.tickResolution = 1;
    
    //Each line is an eigth of a note
    self.lineDeltaTime = (self.midiClock.PPQN / 2);
    
    // Create a new audio manager this will vocalize the midi messages
    self.audioManager = [AudioManager newAudioManager];
    
    // Load the default general midi instruments from the midi file
    //[self.audioManager configureForGeneralMidi:@"memory moog" sf2:@"Steinway Grand Piano" sf3:@"JR_organ" sf4:@"JR_vibra"];
    [self.audioManager addVoice:@"c0" withSound:@"JR__pad" withPatch:0 withVolume:1];
    [self.audioManager addVoice:@"c1" withSound:@"JR_vibra" withPatch:0 withVolume:1];
    [self.audioManager addVoice:@"c2" withSound:@"JR_PADstring" withPatch:0 withVolume:1];
    [self.audioManager addVoice:@"c3" withSound:@"JR_voice2" withPatch:0 withVolume:1];
    self.scale = @"Major";
    self.rootNote = 48; //C4

    // Start the audio manager. After the audio manager has started you can't add any more
    // voices
    [self.audioManager startAudioGraph];

    // Create the audio thread. This is a high priority thread
    // which will update the audio around 400 times per second
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self audioLoop];
    });
}

#pragma mark - Update Methods

-(void) audioLoop
{
    // Loop until the program terminates
    while (true) {
        
        // Update the midi clock every loop
        [self.midiClock update];
        
        // Only check for events if the required number of ticks
        // has elapsed - determined by _midiClock.tickResolution
        NSInteger discreteTime = [self.midiClock getDiscreteTime];
        if([self.midiClock requiredTicksElapsed]) {
            //[self.sequencePlayer update:[self.midiClock getDiscreteTime]];
            [self updateSequence:discreteTime];
            [self.audioManager update:discreteTime];
            
            // We need to check if the metronome has ticked from within the
            // audio loop because it might be missed by the slower render loop
            if([self.midiClock isMetronomeTick]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.metronomeLabel.text = [NSString stringWithFormat:@"%d", (self.metronomeTicks % 4) + 1];
                    if(!(self.metronomeTicks % 4))
                    {
                        //NSLog(@"Setting the new grid (%d ticks)", self.metronomeTicks);
                        self.gridView.grid = self.pool.state;
                    }
                    if(!self.timeOfLastBeat)
                    {
                        self.timeOfLastBeat = [self.midiClock getCurrentTimeMillis] / 1000.0;
                    }
                    else
                    {
                        CFTimeInterval currentBeat = [self.midiClock getCurrentTimeMillis] / 1000.0;
                        if(currentBeat - self.timeOfLastBeat > (self.midiClock.BPM / 60.0))
                        {
                            NSLog(@"*** MIDI Clock skew detected! ***");
                            NSLog(@"*** Last Beat: %g ms, Current Beat: %g ms ***", self.timeOfLastBeat, currentBeat);
                            NSLog(@"*** Beat Durations: %g ***", (self.midiClock.BPM / 60.0));
                        }
                        self.timeOfLastBeat = currentBeat;
                    }
                    self.metronomeTicks ++;
                });
            }
        }
        //Always perform the update on the last eigth note
        if((self.timeForNextUpdate - self.lineDeltaTime) < discreteTime)
        {
            //Update the pool
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self updatePool];
            });
            self.updateTime = discreteTime;
            //Each row is a 8th note
            self.timeForNextUpdate += self.lineDeltaTime * self.numRows;
        }
    }
}

// Play the next notes in the sequence
-(void) updateSequence: (NSInteger) timeInPulses
{    
    // Other pointers we setup to improve efficiency
    BMidiEvent * midiEvent;
    NSMutableArray *toDelete = [[NSMutableArray alloc] init];
    NSMutableArray *sequence;
    @synchronized(self.sequence)
    {
        sequence = [self.sequence mutableCopy];
    }
    NSUInteger count = [sequence count];
    // Loop over sequence and work out if the note should be played
    for(int j=0; j<count; j++) {
        
        // Get a pointer to the current event
        midiEvent = sequence[j];
        
        // If the time is greater than the current time then skip the note
        // and add one to the relaxation counter
        if([midiEvent getStartTime] > timeInPulses) {
            continue;
        }
        
        // Add the note for deleting
        [toDelete addObject:midiEvent];
        [self.completeSong addObject:midiEvent];
        
        if(midiEvent.eventType == Note) {
            [self handleNoteEvent:(BMidiNote *) midiEvent];
        }
        else if(midiEvent.eventType == Tempo ) {
            [self handleTempoEvent:(BTempoEvent *) midiEvent];
        }
    }
    
    // Clean up by deleting used notes
    [sequence removeObjectsInArray:toDelete];
    @synchronized(self.sequence)
    {
        self.sequence = sequence;
    }
}

-(void)updatePool
{
    //NSLog(@"%g: working!", CACurrentMediaTime());
    [self.pool performStep];
    NSMutableArray *grids = [NSMutableArray arrayWithCapacity:self.numPools];
    for(int i = 0; i < self.numPools; i ++)
    {
        [grids addObject:((PoolOfLife *)self.pools[i]).state];
    }
    NSInteger startTime = self.startTimeForNextBar;
    if(!startTime)
    {
        startTime = self.updateTime;
        self.startTimeForNextBar = startTime;
    }
    NSInteger channel = 0;
    NSMutableDictionary *notes = [[NSMutableDictionary alloc] init];
    NSMutableArray *finalNotes = [[NSMutableArray alloc] init];
    for(NSArray *currentGrid in grids)
    {
        for(int row = 0; row < self.numRows; row ++)
        {
            for(int col = 0; col < self.numCols; col ++)
            {
                NSNumber *currentCol = @(col);
                NSInteger dt = row * self.lineDeltaTime;
                if([[notes allKeys] containsObject:currentCol])
                {
                    if([currentGrid[row][col] intValue])
                    {
                        //Update the note in the dictionary
                        BMidiNote *note = notes[currentCol];
                        [note setDuration:([note getDuration] + self.lineDeltaTime)];
                    }
                    else
                    {
                        //Remove the note from the dictionary and insert it into finalNotes
                        BMidiNote *noteToAdd = notes[currentCol];
                        //                        BMidiNote *noteOff = [[BMidiNote alloc] init];
                        //                        noteOff.note = noteToAdd.note;
                        //                        noteOff.channel = 0;
                        //                        noteOff.velocity = 0;
                        //                        [noteOff setStartTime:[noteToAdd getStartTime] + [noteToAdd getDuration]];
                        //                        [finalNotes addObject:noteOff];
                        [finalNotes addObject:noteToAdd];
                        [notes removeObjectForKey:currentCol];
                    }
                }
                else
                {
                    if((channel = [currentGrid[row][col] intValue]))
                    {
                        //Create a new note and insert it into the dictionary
                        BMidiNote *note = [[BMidiNote alloc] init];
                        note.channel = (channel - 1);
                        note.velocity = 127;
                        note.note = [self convertToMidi:col voice:(channel - 1)];
                        [note setStartTime:(startTime + dt)];
                        [note setDuration:self.lineDeltaTime];
                        notes[currentCol] = note;
                    }
                }
            }
        }
    }
    [finalNotes addObjectsFromArray:[notes allValues]];
    NSInteger deltaTime = self.numRows * self.lineDeltaTime;
    self.startTimeForNextBar += deltaTime;
    @synchronized(self.sequence)
    {
        self.sequence = finalNotes;
    }
}

// http://www.midimountain.com/midi/midi_note_numbers.html
-(int)convertToMidi:(int)note voice:(int)voice
{
    NSArray *scaleArray = kSCALES[self.scale];
    NSInteger count = [scaleArray count];
    int midiNote = [[scaleArray objectAtIndex:(note % count)] intValue] + (12 * (note / count)) + self.rootNote;
    return midiNote;
}

#pragma mark - Dealloc

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    //Model
    for(PoolOfLife *pool in self.pools)
    {
        pool.delegate = nil;
    }
    self.pools = nil;
    //MIDI
    self.midiClock = nil;
    self.sequencePlayer = nil;
    self.audioManager = nil;
}

@end
