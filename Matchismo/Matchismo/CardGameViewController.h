//
//  MatchismoViewController.h
//  Matchismo
//
//  Created by Vasco Orey on 2/1/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "GameSettings.h"

@interface CardGameViewController : UIViewController

// Abstract
@property (nonatomic, strong) NSString *gameName;
-(Deck *)createDeck;
-(void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card animate:(BOOL)animate;
-(GameSettings *)settings;

@end
