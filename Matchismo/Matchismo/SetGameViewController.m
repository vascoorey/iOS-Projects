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

-(void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card animate:(BOOL)animate
{
    
}

-(GameSettings *)settings
{
    return [[GameSettings alloc] initWithFlipCost:1 matchBonus:6 mismatchPenalty:3 matchMode:3 shouldRedealCards:YES startingCardCount:12];
}

@end
