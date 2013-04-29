//
//  OptionsViewController.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 4/27/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "OptionsViewController.h"

@interface OptionsViewController ()
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *panSlider;
@property (nonatomic) NSInteger currentVoice;
@end

@implementation OptionsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)changeVolume:(UISlider *)sender {
    [self.delegate setVolume:sender.value forVoice:self.currentVoice];
}

- (IBAction)changePan:(UISlider *)sender {
    [self.delegate setPan:sender.value forVoice:self.currentVoice];
}

- (IBAction)changeSelectedVoice:(UISegmentedControl *)sender {
    self.currentVoice = sender.selectedSegmentIndex;
    self.volumeSlider.value = [self.delegate volumeForVoice:self.currentVoice];
    self.panSlider.value = [self.delegate panForVoice:self.currentVoice];
}

@end
