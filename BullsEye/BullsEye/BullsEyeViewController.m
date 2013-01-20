//
//  BullsEyeViewController.m
//  BullsEye
//
//  Created by Vasco Orey on 1/19/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "BullsEyeViewController.h"

@interface BullsEyeViewController ()

@end

@implementation BullsEyeViewController

@synthesize currentValue = _currentValue;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bull's Eye"
                                                        message:[NSString stringWithFormat:@"Slider value: %d", self.currentValue]
                                                       delegate:nil
                                              cancelButtonTitle:@"Sweet !"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(IBAction)sliderMoved:(UISlider *)slider
{
    self.currentValue = lroundf(slider.value);
}

@end
