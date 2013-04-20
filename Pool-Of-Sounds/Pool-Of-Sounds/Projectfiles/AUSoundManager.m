//
//  SoundManager.m
//  Game-Of-Life
//
//  Created by Vasco Orey on 4/12/13.
//
//A lot of code from: https://developer.apple.com/library/ios/#samplecode/LoadPresetDemo/Introduction/Intro.html#//apple_ref/doc/uid/DTS40011214-Intro-DontLinkElementID_2

#import "AUSoundManager.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AssertMacros.h>

// some MIDI constants:
enum {
	kMIDIMessage_NoteOn    = 0x9,
	kMIDIMessage_NoteOff   = 0x8,
};

@interface AUSoundManager ()
@property (nonatomic, strong) NSMutableArray *notesBeingPlayed;
@property (readwrite) Float64   graphSampleRate;
@property (readwrite) AUGraph   processingGraph;
@property (readwrite) AudioUnit samplerUnit;
@property (readwrite) AudioUnit ioUnit;
@property (readwrite) AudioUnit limiterUnit;

- (OSStatus)    loadSynthFromPresetURL:(NSURL *) presetURL;
- (void)        registerForUIApplicationNotifications;
- (BOOL)        createAUGraph;
- (void)        configureAndStartAudioProcessingGraph: (AUGraph) graph;
- (void)        stopAudioProcessingGraph;
- (void)        restartAudioProcessingGraph;
@end

@implementation AUSoundManager

#pragma mark - AudioUnit

@synthesize graphSampleRate     = _graphSampleRate;
@synthesize samplerUnit         = _samplerUnit;
@synthesize ioUnit              = _ioUnit;
@synthesize processingGraph     = _processingGraph;

#pragma mark -
#pragma mark Audio setup


// Create an audio processing graph.
- (BOOL) createAUGraph {
    
	OSStatus result = noErr;
	AUNode samplerNode, ioNode, limiterNode;
    
    // Specify the common portion of an audio unit's identify, used for both audio units
    // in the graph.
	AudioComponentDescription cd = {};
	cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
	cd.componentFlags            = 0;
	cd.componentFlagsMask        = 0;
    AudioComponentDescription limiter = {};
    limiter.componentManufacturer = kAudioUnitManufacturer_Apple;
    limiter.componentFlags = 0;
    limiter.componentFlagsMask = 0;
    
    // Instantiate an audio processing graph
	result = NewAUGraph (&_processingGraph);
    NSCAssert (result == noErr, @"Unable to create an AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	//Specify the Sampler unit, to be used as the first node of the graph
	cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_Sampler;
	
    // Add the Sampler unit node to the graph
	result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Specify the Output unit, to be used as the second and final node of the graph
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_RemoteIO;
    
    // Add the Output unit node to the graph
	result = AUGraphAddNode (self.processingGraph, &cd, &ioNode);
    NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Open the graph
	result = AUGraphOpen (self.processingGraph);
    NSCAssert (result == noErr, @"Unable to open the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    limiter.componentType = kAudioUnitType_Effect;
    limiter.componentSubType = kAudioUnitSubType_PeakLimiter;
    
    result = AUGraphAddNode(self.processingGraph, &limiter, &limiterNode);
    NSCAssert(result == noErr, @"Unable to add the peak limiter");
    
    // Connect the Sampler unit to the output unit
	result = AUGraphConnectNodeInput (self.processingGraph, samplerNode, 0, limiterNode, 0);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Obtain a reference to the Sampler unit from its node
	result = AUGraphNodeInfo (self.processingGraph, samplerNode, 0, &_samplerUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Obtain a reference to the I/O unit from its node
	result = AUGraphNodeInfo (self.processingGraph, ioNode, 0, &_ioUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphNodeInfo(self.processingGraph, limiterNode, 0, &_limiterUnit);
    
    return YES;
}


// Starting with instantiated audio processing graph, configure its
// audio units, initialize it, and start it.
- (void) configureAndStartAudioProcessingGraph: (AUGraph) graph {
    
    OSStatus result = noErr;
    UInt32 framesPerSlice = 0;
    UInt32 framesPerSlicePropertySize = sizeof (framesPerSlice);
    UInt32 sampleRatePropertySize = sizeof (self.graphSampleRate);
    
    result = AudioUnitInitialize (self.ioUnit);
    NSCAssert (result == noErr, @"Unable to initialize the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Set the I/O unit's output sample rate.
    result =    AudioUnitSetProperty (
                                      self.ioUnit,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Obtain the value of the maximum-frames-per-slice from the I/O unit.
    result =    AudioUnitGetProperty (
                                      self.ioUnit,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      &framesPerSlicePropertySize
                                      );
    
    NSCAssert (result == noErr, @"Unable to retrieve the maximum frames per slice property from the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Set the Sampler unit's output sample rate.
    result =    AudioUnitSetProperty (
                                      self.samplerUnit,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    // Set the Sampler unit's maximum frames-per-slice.
    result =    AudioUnitSetProperty (
                                      self.samplerUnit,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      framesPerSlicePropertySize
                                      );
    
    NSAssert( result == noErr, @"AudioUnitSetProperty (set Sampler unit maximum frames per slice). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    if (graph) {
        
        // Initialize the audio processing graph.
        result = AUGraphInitialize (graph);
        NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Start the graph
        result = AUGraphStart (graph);
        NSAssert (result == noErr, @"Unable to start audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Print out the graph to the console
        CAShow (graph);
    }
}


// Load a preset
-(void)loadPreset:(NSString *)preset {
    
	NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:preset ofType:@"aupreset"]];
	if (presetURL) {
		NSLog(@"Attempting to load preset '%@'\n", [presetURL description]);
	}
	else {
		NSLog(@"COULD NOT GET PRESET PATH!");
	}
    
	[self loadSynthFromPresetURL: presetURL];
}

// Load a synthesizer preset file and apply it to the Sampler unit
- (OSStatus) loadSynthFromPresetURL: (NSURL *) presetURL {
    
	CFDataRef propertyResourceData = 0;
	Boolean status;
	SInt32 errorCode = 0;
	OSStatus result = noErr;
	
	// Read from the URL and convert into a CFData chunk
	status = CFURLCreateDataAndPropertiesFromResource (
                                                       kCFAllocatorDefault,
                                                       (__bridge CFURLRef) presetURL,
                                                       &propertyResourceData,
                                                       NULL,
                                                       NULL,
                                                       &errorCode
                                                       );
    
    NSAssert (status == YES && propertyResourceData != 0, @"Unable to create data and properties from a preset. Error code: %d '%.4s'", (int) errorCode, (const char *)&errorCode);
   	
	// Convert the data object into a property list
	CFPropertyListRef presetPropertyList = 0;
	CFPropertyListFormat dataFormat = 0;
	CFErrorRef errorRef = 0;
	presetPropertyList = CFPropertyListCreateWithData (
                                                       kCFAllocatorDefault,
                                                       propertyResourceData,
                                                       kCFPropertyListImmutable,
                                                       &dataFormat,
                                                       &errorRef
                                                       );
    
    // Set the class info property for the Sampler unit using the property list as the value.
	if (presetPropertyList != 0) {
		
		result = AudioUnitSetProperty(
                                      self.samplerUnit,
                                      kAudioUnitProperty_ClassInfo,
                                      kAudioUnitScope_Global,
                                      0,
                                      &presetPropertyList,
                                      sizeof(CFPropertyListRef)
                                      );
        
		CFRelease(presetPropertyList);
	}
    
    if (errorRef) CFRelease(errorRef);
	CFRelease (propertyResourceData);
    
	return result;
}


// Set up the audio session for this app.
- (BOOL) setupAudioSession {
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    // Specify that this object is the delegate of the audio session, so that
    //    this object's endInterruption method will be invoked when needed.
    // mySession.delegate = self; -> Changed to Notification (see registerForUIApplicationNotifications)
    
    // Assign the Playback category to the audio session. This category supports
    //    audio output with the Ring/Silent switch in the Silent position.
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayback error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error setting audio session category."); return NO;}
    
    // Request a desired hardware sample rate.
    self.graphSampleRate = 44100.0;    // Hertz
    
    [mySession setPreferredSampleRate: self.graphSampleRate error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error setting preferred hardware sample rate."); return NO;}
    
    // Activate the audio session
    [mySession setActive: YES error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error activating the audio session."); return NO;}
    
    // Obtain the actual hardware sample rate and store it for later use in the audio processing graph.
    self.graphSampleRate = [mySession sampleRate];
    
    return YES;
}


#pragma mark -
#pragma mark Audio control

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
-(UInt32)convertToMidi:(NSInteger)note
{
    NSInteger count = [C_MAJ_ARPEGGIOS count];
    return [[C_MAJ_ARPEGGIOS objectAtIndex:(note % count)] unsignedIntValue] + 12 + (12 * (note / count));
}

-(void)startPlayNote:(NSInteger)note intensity:(float)intensity
{
    UInt32 noteNum = [self convertToMidi:note];
	UInt32 onVelocity = (UInt32)(127.0f * intensity);
    //NSLog(@"velocity: %d (%g)", (int)onVelocity, intensity);
	UInt32 noteCommand = 	kMIDIMessage_NoteOn << 4 | 0;
    
    [self.notesBeingPlayed addObject:@(note)];
    
    OSStatus result = noErr;
	require_noerr (result = MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, onVelocity, 0), logTheError);
    
logTheError:
    if (result != noErr) NSLog (@"Unable to start playing the note. Error code: %d '%.4s'\n", (int) result, (const char *)&result);
}

-(void)stopPlayNote:(NSInteger)note
{
    UInt32 noteNum = [self convertToMidi:note];
	UInt32 noteCommand = 	kMIDIMessage_NoteOff << 4 | 0;
    
    [self.notesBeingPlayed removeObject:@(note)];
	
    OSStatus result = noErr;
	require_noerr (result = MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, 0, 0), logTheError);
    
logTheError:
    if (result != noErr) NSLog (@"Unable to stop playing the note. Error code: %d '%.4s'", (int) result, (const char *)&result);
}

-(void)stopAllNotes
{
    NSArray *notesToStop = [self.notesBeingPlayed copy];
    for(NSNumber *note in notesToStop)
    {
        [self stopPlayNote:[note intValue]];
    }
}

// Stop the audio processing graph
- (void) stopAudioProcessingGraph {
    
    OSStatus result = noErr;
	if (self.processingGraph) result = AUGraphStop(self.processingGraph);
    NSAssert (result == noErr, @"Unable to stop the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
}

// Restart the audio processing graph
- (void) restartAudioProcessingGraph {
    
    OSStatus result = noErr;
	if (self.processingGraph) result = AUGraphStart (self.processingGraph);
    NSAssert (result == noErr, @"Unable to restart the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
}


#pragma mark -
#pragma mark Audio session delegate methods

// Respond to an audio interruption notification, maybe caused by a phone call or a Clock alarm.
- (void) handleInterruption:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSUInteger interruptionType = (NSUInteger)userInfo[AVAudioSessionInterruptionTypeKey];
    if(interruptionType == AVAudioSessionInterruptionTypeBegan)
    {
        [self beginInterruption];
    }
    else if(interruptionType == AVAudioSessionInterruptionTypeEnded)
    {
        [self endInterruptionWithFlags:((NSUInteger)userInfo[AVAudioSessionInterruptionOptionKey])];
    }
}

-(void)beginInterruption
{
    // Stop any notes that are currently playing.
    [self stopAllNotes];
    
    // Interruptions do not put an AUGraph object into a "stopped" state, so
    //    do that here.
    [self stopAudioProcessingGraph];
}


// Respond to the ending of an audio interruption.
- (void) endInterruptionWithFlags: (NSUInteger) flags {
    
    NSError *endInterruptionError = nil;
    [[AVAudioSession sharedInstance] setActive: YES
                                         error: &endInterruptionError];
    if (endInterruptionError != nil) {
        
        NSLog (@"Unable to reactivate the audio session.");
        return;
    }
    
    if (flags & AVAudioSessionInterruptionOptionShouldResume) {
        
        /*
         In a shipping application, check here to see if the hardware sample rate changed from
         its previous value by comparing it to graphSampleRate. If it did change, reconfigure
         the ioInputStreamFormat struct to use the new sample rate, and set the new stream
         format on the two audio units. (On the mixer, you just need to change the sample rate).
         
         Then call AUGraphUpdate on the graph before starting it.
         */
        
        [self restartAudioProcessingGraph];
    }
}


#pragma mark - Application state management

// The audio processing graph should not run when the screen is locked or when the app has
//  transitioned to the background, because there can be no user interaction in those states.
//  (Leaving the graph running with the screen locked wastes a significant amount of energy.)
//
// Responding to these UIApplication notifications allows this class to stop and restart the 
//    graph as appropriate.
- (void) registerForUIApplicationNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handleResigningActive:)
                               name: UIApplicationWillResignActiveNotification
                             object: [UIApplication sharedApplication]];
    
    [notificationCenter addObserver: self
                           selector: @selector (handleBecomingActive:)
                               name: UIApplicationDidBecomeActiveNotification
                             object: [UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleInterruption:)
                               name:AVAudioSessionInterruptionNotification
                             object:nil];
}


- (void) handleResigningActive: (id) notification {
    
    [self stopAllNotes];
    [self stopAudioProcessingGraph];
}


- (void) handleBecomingActive: (id) notification {
    
    [self restartAudioProcessingGraph];
}

#pragma mark -

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
        self.playing = YES;
        
        // Set up the audio session for this app, in the process obtaining the
        // hardware sample rate for use in the audio processing graph.
        BOOL audioSessionActivated = [self setupAudioSession];
        NSAssert (audioSessionActivated == YES, @"Unable to set up audio session.");
        
        // Create the audio processing graph; place references to the graph and to the Sampler unit
        // into the processingGraph and samplerUnit instance variables.
        [self createAUGraph];
        [self configureAndStartAudioProcessingGraph: self.processingGraph];
        
        [self loadPreset:@"Another"];
        [self registerForUIApplicationNotifications];
    }
    return self;
}

-(void)pushRow:(NSArray *)row
{
    [self pushRow:row intensity:1.0f];
}

-(void)pushRow:(NSArray *)row intensity:(float)intensity
{
    if(self.isPlaying)
    {
        for(NSUInteger noteIndex = 0; noteIndex < [row count]; noteIndex ++)
        {
            NSInteger on = [row[noteIndex] intValue];
            if(on && ![self.notesBeingPlayed containsObject:@(noteIndex)])
            {
                //Start this note
                [self startPlayNote:noteIndex intensity:intensity];
            }
            else if(!on && [self.notesBeingPlayed containsObject:@(noteIndex)])
            {
                //Stop this note
                [self stopPlayNote:noteIndex];
            }
        }
    }
}

-(void)playNoteForCol:(NSInteger)col
{
    [self playNoteForCol:col intensity:1.0f];
}

-(void)playNoteForCol:(NSInteger)col intensity:(float)intensity
{
    [self startPlayNote:col intensity:intensity];
}

-(void)stopPlaying
{
    [self stopAllNotes];
}

@end
