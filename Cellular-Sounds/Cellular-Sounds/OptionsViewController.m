//
//  OptionsViewController.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 4/27/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "OptionsViewController.h"

@interface OptionsViewController ()
@property (weak, nonatomic) IBOutlet UISlider *voiceZeroSlider;
@property (weak, nonatomic) IBOutlet UISlider *voiceOneSlider;
@property (weak, nonatomic) IBOutlet UISlider *voiceTwoSlider;
@property (weak, nonatomic) IBOutlet UISlider *voiceThreeSlider;
@end

@implementation OptionsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.voiceZeroSlider.value = [self.delegate volumeForVoice:0];
    self.voiceOneSlider.value = [self.delegate volumeForVoice:1];
    self.voiceTwoSlider.value = [self.delegate volumeForVoice:2];
    self.voiceThreeSlider.value = [self.delegate volumeForVoice:3];
}

- (IBAction)changeVolume:(UISlider *)sender {
    [self.delegate setVolume:sender.value forVoice:sender.tag];
}

@end
