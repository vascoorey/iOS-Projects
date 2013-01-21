//
//  BullsEyeViewController.m
//  BullsEye
//
//  Created by Vasco Orey on 1/19/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BullsEyeViewController.h"
#import "AboutViewController.h"

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
    
    // Slider Images
    // Set image for normal state
    UIImage *thumbImageNormal = [UIImage imageNamed:@"SliderThumb-Normal"];
    [self.slider setThumbImage:thumbImageNormal forState:UIControlStateNormal];
    // Set image for highlighted state
    UIImage *thumbImageHighlighted = [UIImage imageNamed:@"SliderThumb-Highlighted"];
    [self.slider setThumbImage:thumbImageHighlighted forState:UIControlStateHighlighted];
    // Set left tracking image
    UIImage *leftTrackingImage = [[UIImage imageNamed:@"SliderTrackLeft"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    [self.slider setMinimumTrackImage:leftTrackingImage forState:UIControlStateNormal];
    // Set right tracking image
    UIImage *rightTrackingImage = [[UIImage imageNamed:@"SliderTrackRight"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    [self.slider setMaximumTrackImage:rightTrackingImage forState:UIControlStateNormal];
    
    // Reset the game (in order to start it)
    [self reset];
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
    int difference = abs((int)lroundf(self.slider.value) - self.targetValue);
    self.score = 100 - difference;
    
    NSString *title;
    if(!difference) {
        title = @"Perfect !";
        self.score += 100;
    } else if(difference < 5) {
        if(difference == 1) {
            self.score += 50;
        }
        title = @"Almost had it !";
    } else if(difference < 10) {
        title = @"Not bad...";
    } else {
        title = @"Not even close !";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:[NSString stringWithFormat:@"Your score: %d", self.score]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(IBAction)reset
{
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self startNewRound];
    self.scoreLabel.text = @"0";
    self.roundLabel.text = @"1";
    
    [self.view.layer addAnimation:transition forKey:nil];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self startNewRound];
}

-(void)startNewRound
{
    // Reset the slider to 50
    self.slider.value = 50;
    // Generate new target value (model)
    self.targetValue = 1 + arc4random() % 100;
    // Update the labels to reflect the last round and the new target.
    self.targetLabel.text = [NSString stringWithFormat:@"%d", self.targetValue];
    // May be a future cause of complaints...
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score + [self.scoreLabel.text intValue]];
    self.roundLabel.text = [NSString stringWithFormat:@"%d", 1 + [self.roundLabel.text intValue]];
}

-(IBAction)showInfo
{
    AboutViewController *aboutView = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    aboutView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:aboutView animated:YES completion:nil];
}

@end
