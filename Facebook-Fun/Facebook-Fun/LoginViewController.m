//
//  LoginViewController.m
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/26/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()
@end

@implementation LoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
}

- (IBAction)performLogin {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

-(void)sessionStateChanged:(NSNotification *)notification
{
    if ([[FBSession activeSession] isOpen]) {
        // Rewind segue
        [self performSegueWithIdentifier:@"loginComplete:" sender:self];
    }
    else
    {
        UIAlertView *alertView
        = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error with login... Sorry!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
