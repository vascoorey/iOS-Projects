//
//  SuperCardViewController.m
//  SuperCard
//
//  Created by Vasco Orey on 2/18/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "SuperCardViewController.h"
#import "PlayingCardView.h"

@interface SuperCardViewController ()
@property (weak, nonatomic) IBOutlet PlayingCardView *playingCardView;
@end

@implementation SuperCardViewController

-(void)setPlayingCardView:(PlayingCardView *)playingCardView
{
    _playingCardView = playingCardView;
    playingCardView.rank = 13; // K
    playingCardView.suit = @"♥";
}

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

@end
