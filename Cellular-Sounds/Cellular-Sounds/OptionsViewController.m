//
//  OptionsViewController.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 4/27/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "OptionsViewController.h"
#import "NoteDefs.h"

@interface OptionsViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *panSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *voiceSegmentedControl;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@end

@implementation OptionsViewController

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(!component)
    {
        [self.delegate setRootNote:row forVoice:self.currentVoice];
    }
    else
    {
        [self.delegate setScale:[kSCALES allKeys][row] forVoice:self.currentVoice];
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"none";
    if(!component)
    {
        //First picker
        NSInteger key = row / 12;
        NSInteger noteNum = row % 12;
        title = kNOTE_NAMES[noteNum];
        if(!noteNum)
        {
            title = [title stringByAppendingFormat:@"%i", key];
        }
    }
    else if(component == 1)
    {
        //Second picker
        title = [kSCALES allKeys][row];
    }
    return title;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = 0;
    if(!component)
    {
        //First picker
        rows = kNOTES;
    }
    else if(component == 1)
    {
        //Second picker
        rows = [[kSCALES allKeys] count];
    }
    return rows;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(void)refresh
{
    self.volumeSlider.value = [self.delegate volumeForVoice:self.currentVoice];
    self.panSlider.value = [self.delegate panForVoice:self.currentVoice];
    self.voiceSegmentedControl.selectedSegmentIndex = self.currentVoice;
    [self.pickerView selectRow:[self.delegate rootNoteForVoice:self.currentVoice] inComponent:0 animated:YES];
    NSInteger pickedScale = [[kSCALES allKeys] indexOfObject:[self.delegate scaleForVoice:self.currentVoice]];
    [self.pickerView selectRow:pickedScale inComponent:1 animated:YES];
}

- (IBAction)killPressed:(id)sender {
    [self.delegate killAudio];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

- (IBAction)changeVolume:(UISlider *)sender {
    [self.delegate setVolume:sender.value forVoice:self.currentVoice];
}

- (IBAction)changePan:(UISlider *)sender {
    [self.delegate setPan:sender.value forVoice:self.currentVoice];
}

- (IBAction)changeSelectedVoice:(UISegmentedControl *)sender {
    self.currentVoice = sender.selectedSegmentIndex;
    [self refresh];
}

@end
