//
//  KitchenSinkViewController.m
//  Kitchen-Sink
//
//  Created by Vasco Orey on 3/15/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "KitchenSinkViewController.h"
#import "AskerViewController.h"

@interface KitchenSinkViewController ()

@end

@implementation KitchenSinkViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Ask"])
    {
        AskerViewController *asker = segue.destinationViewController;
        asker.question = @"What food do you want in the sink?";
    }
}

-(IBAction)cancelAsking:(UIStoryboardSegue *)segue
{
    
}

-(IBAction)doneAsking:(UIStoryboardSegue *)segue
{
    AskerViewController *asker = segue.sourceViewController;
    NSLog(@"%@", asker.answer);
}
@end
