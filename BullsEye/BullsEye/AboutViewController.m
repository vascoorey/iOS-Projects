//
//  AboutViewController.m
//  BullsEye
//
//  Created by Vasco Orey on 1/20/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "AboutViewController.h"
#import "BullsEyeViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

-(IBAction)close
{
    BullsEyeViewController *bullsEye = [[BullsEyeViewController alloc] initWithNibName:@"BullsEyeViewController" bundle:nil];
    bullsEye.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:bullsEye animated:YES completion:nil];
}

@end
