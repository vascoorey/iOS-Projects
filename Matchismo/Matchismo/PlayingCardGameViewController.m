//
//  PlayingCardGameViewController.m
//  Matchismo
//
//  Created by Vasco Orey on 2/18/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PlayingCardGameViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "PlayingCardCollectionViewCell.h"
#import "AllGameSettings.h"

@interface PlayingCardGameViewController ()

@end

@implementation PlayingCardGameViewController

-(NSString *)gameName
{
    return @"Match";
}

-(Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}

-(NSUInteger)cardsToAdd
{
    return 2;
}

-(GameSettings *)settings
{
    return [[GameSettings alloc] initWithFlipCost:1 matchBonus:6 mismatchPenalty:4 matchMode:2 startingCardCount:22];
}

-(void)userCheatedSoUpdateCell:(UICollectionViewCell *)cell
{
    if([cell isKindOfClass:[PlayingCardCollectionViewCell class]])
    {
        PlayingCardView *playingCardView = ((PlayingCardCollectionViewCell *)cell).playingCardView;
        playingCardView.markForCheating = YES;
    }
}

-(void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card animate:(BOOL)animate
{
    if([cell isKindOfClass:[PlayingCardCollectionViewCell class]])
    {
        PlayingCardView *playingCardView = ((PlayingCardCollectionViewCell *)cell).playingCardView;
        if([card isKindOfClass:[PlayingCard class]])
        {
            PlayingCard *playingCard = (PlayingCard *)card;
            
            // Are we really going to animate ? !faceUp -> faceUp .. faceUp -> !faceUp
            animate = animate ? (playingCard.isFaceUp != playingCardView.faceUp) : NO;
            
            playingCardView.rank = playingCard.rank;
            playingCardView.suit = playingCard.suit;
            playingCardView.faceUp = playingCard.isFaceUp;
            playingCardView.alpha = playingCard.isUnplayable ? 0.3f : 1.0f;
            playingCardView.markForCheating = NO;
            if(animate)
            {
                [UIView transitionWithView:playingCardView
                                  duration:0.5f
                                   options:UIViewAnimationOptionTransitionFlipFromLeft
                                animations:nil
                                completion:NULL];
            }
        }
    }
}

@end
