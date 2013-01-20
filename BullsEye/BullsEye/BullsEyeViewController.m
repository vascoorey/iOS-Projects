//
//  BullsEyeViewController.m
//  BullsEye
//
//  Created by Vasco Orey on 1/19/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "BullsEyeViewController.h"

@interface BullsEyeViewController ()
-(void)startNewRound;
@end

@implementation BullsEyeViewController

@synthesize slider = _slider;
@synthesize targetLabel = _targetLabel;
@synthesize targetValue = _targetValue;
@synthesize score = _score;
@synthesize scoreLabel = _scoreLabel;
@synthesize roundLabel = _roundLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self startNewRound];
    self.scoreLabel.text = @"0";
    self.roundLabel.text = @"1";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

-(IBAction)showAlert
{
    int sliderValue = (int)lroundf(self.slider.value);
    self.score = 100 - abs(sliderValue - self.targetValue);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Aiming for %d...", self.targetValue]
                                                        message:[NSString stringWithFormat:@"Your bet: %d, Your score: %d", sliderValue, self.score]
                                                       delegate:nil
                                              cancelButtonTitle:@"Sweet !"
                                              otherButtonTitles:nil];
    [alertView show];
    [self startNewRound];
}

-(void)startNewRound
{
    // Generate new target value (model)
    self.targetValue = 1 + arc4random() % 100;
    // Update the labels to reflect the last round and the new target.
    self.targetLabel.text = [NSString stringWithFormat:@"%d", self.targetValue];
    // May be a future cause of complaints...
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score + [self.scoreLabel.text intValue]];
    self.roundLabel.text = [NSString stringWithFormat:@"%d", 1 + [self.roundLabel.text intValue]];
}

@end
