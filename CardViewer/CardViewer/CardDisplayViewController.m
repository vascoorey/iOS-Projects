//
//  CardDisplayViewController.m
//  CardViewer
//
//  Created by Vasco Orey on 2/20/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CardDisplayViewController.h"
#import "PlayingCardView.h"

@interface CardDisplayViewController ()
@property (nonatomic, strong) IBOutlet PlayingCardView *playingCardView;
@end

@implementation CardDisplayViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.playingCardView.rank = self.rank;
    self.playingCardView.suit = self.suit;
    self.playingCardView.faceUp = YES;
}

@end
