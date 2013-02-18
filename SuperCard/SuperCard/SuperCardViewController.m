//
//  SuperCardViewController.m
//  SuperCard
//
//  Created by Vasco Orey on 2/18/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "SuperCardViewController.h"
#import "PlayingCardView.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@interface SuperCardViewController ()
@property (weak, nonatomic) IBOutlet PlayingCardView *playingCardView;
@property (strong, nonatomic) Deck *deck;
@end

@implementation SuperCardViewController

-(Deck *)deck
{
    if(!_deck)
    {
        _deck = [[PlayingCardDeck alloc] init];
    }
    return _deck;
}

-(void)setPlayingCardView:(PlayingCardView *)playingCardView
{
    _playingCardView = playingCardView;
    [self drawRandomPlayingCard];
    [playingCardView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:playingCardView action:@selector(pinch:)]];
}

-(void)drawRandomPlayingCard
{
    Card *card = [self.deck drawRandomCard];
    if([card isKindOfClass:[PlayingCard class]])
    {
        PlayingCard *playingCard = (PlayingCard *)card;
        self.playingCardView.rank = playingCard.rank;
        self.playingCardView.suit = playingCard.suit;
    }
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
    [UIView transitionWithView:self.playingCardView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        if(!self.playingCardView.faceUp)
                        {
                            [self drawRandomPlayingCard];
                        }
                        self.playingCardView.faceUp = !self.playingCardView.faceUp;
                    }
                    completion:NULL];
}

@end
