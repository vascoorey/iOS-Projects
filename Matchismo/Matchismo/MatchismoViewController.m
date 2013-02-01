//
//  MatchismoViewController.m
//  Matchismo
//
//  Created by Vasco Orey on 2/1/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "MatchismoViewController.h"

@interface MatchismoViewController ()

@end

@implementation MatchismoViewController

- (IBAction)didFlipCard:(UIButton *)sender {
    sender.selected = !sender.selected;
}

@end
