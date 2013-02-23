//
//  SetGameViewController.m
//  Matchismo
//
//  Created by Vasco Orey on 2/9/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "SetGameViewController.h"
#import "SetCardDeck.h"
#import "SetCard.h"
#import "AllGameSettings.h"
#import "SetCardCollectionViewCell.h"

#define FONT_SIZE 17
#define FONT_NAME @"Arial Rounded MT Bold"
#define BUTTON_ALPHA 0.167f

@interface SetGameViewController()
@end

@implementation SetGameViewController

-(NSString *)gameName
{
    return @"Set";
}

-(Deck *)createDeck
{
    return [[SetCardDeck alloc] init];
}

-(void)userCheatedSoUpdateCell:(UICollectionViewCell *)cell
{
    if([cell isKindOfClass:[SetCardCollectionViewCell class]])
    {
        SetCardView *setCardView = ((SetCardCollectionViewCell *)cell).setCardView;
        setCardView.markForCheating = !setCardView.faceUp;
    }
}

-(void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card animate:(BOOL)animate
{
    if([cell isKindOfClass:[SetCardCollectionViewCell class]])
    {
        SetCardView *setCardView = ((SetCardCollectionViewCell *)cell).setCardView;
        if([card isKindOfClass:[SetCard class]])
        {
            SetCard *setCard = (SetCard *)card;
            
            // Are we really going to animate ? !faceUp -> faceUp .. faceUp -> !faceUp
            // animate = animate ? (setCard.isFaceUp != setCardView.faceUp) : NO;
            // Set will only animate deletions !
            
            setCardView.numberOfShapes = setCard.numberOfShapes;
            setCardView.color = setCard.color;
            setCardView.shape = setCard.shape;
            setCardView.shade = setCard.shade;
            setCardView.faceUp = setCard.isFaceUp;
            setCardView.markForCheating = setCard.isMarkedForCheating;
            setCard.markedForCheating = NO;
        }
    }
}

-(NSUInteger) cardsToAdd
{
    return 3;
}

-(GameSettings *)settings
{
    GameSettings *settings = [[GameSettings alloc] initWithFlipCost:1 matchBonus:6 mismatchPenalty:3 matchMode:3 startingCardCount:12];
    settings.penalizeCheating = YES;
    return settings;
}

@end
