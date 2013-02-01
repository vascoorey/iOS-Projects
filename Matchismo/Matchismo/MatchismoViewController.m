//
//  MatchismoViewController.m
//  Matchismo
//
//  Created by Vasco Orey on 2/1/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "MatchismoViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@interface MatchismoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (nonatomic) NSInteger flipCount;
@property (nonatomic, strong) PlayingCardDeck *deck;

@end

@implementation MatchismoViewController

-(PlayingCardDeck *)deck
{
    if(!_deck)
    {
        _deck = [[PlayingCardDeck alloc] init];
    }
    return _deck;
}

-(void)setFlipCount:(NSInteger)flipCount
{
    _flipCount = flipCount;
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipCount];
}

- (IBAction)flipCard:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if(sender.isSelected)
    {
        [sender setTitle:[[self.deck drawRandomCard] description] forState:UIControlStateSelected];
        self.flipCount ++;
    }
}

@end
