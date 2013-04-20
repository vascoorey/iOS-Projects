//
//  ViewController.m
//  MomuMandolin
//
//  Created by Vasco Orey on 4/20/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#include "Stk.h"
#include "Mandolin.h"
#import "mo_audio.h"
#import "ViewController.h"

using namespace stk;

struct AudioData {
    Mandolin *myMandolin;
};

@interface ViewController ()
{
    struct AudioData _audioData;
}
-(IBAction)pluckMandolin;
@end

@implementation ViewController

#define SRATE 44100
#define FRAMESIZE 128
#define NUMCHANNELS 2

void audioCallback(Float32 *buffer, UInt32 frameSize, void *userData)
{
    AudioData *data = (AudioData *)userData;
    for(int i = 0; i < frameSize; i ++)
    {
        SAMPLE out = data->myMandolin->tick();
        buffer[2*i] = buffer[2*i+1] = out;
    }
}

-(IBAction)pluckMandolin
{
    for(int i = 0; i < 10; i ++)
    {
        _audioData.myMandolin->pluck(1);
        _audioData.myMandolin->setFrequency(arc4random() % 560);
    }
}

-(void)viewDidLoad
{
    _audioData.myMandolin = new Mandolin(400);
    _audioData.myMandolin->setFrequency(400);
    BOOL result = MoAudio::init(SRATE, FRAMESIZE, NUMCHANNELS);
    if(!result)
    {
        NSLog(@"Error setting up audio.");
        return;
    }
    result = MoAudio::start(audioCallback, &_audioData);
    if(!result)
    {
        NSLog(@"Can't setup realtime audio!");
    }
}

@end
