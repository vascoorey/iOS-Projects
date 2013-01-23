//
//  AddItemViewController.m
//  Checklists
//
//  Created by Vasco Orey on 1/23/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "AddItemViewController.h"

@interface AddItemViewController ()

@end

@implementation AddItemViewController

-(IBAction)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)done
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
