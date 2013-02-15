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
#import "CardMatchingGame.h"
#import "GameResult.h"
#import "AllGameSettings.h"

@interface SetGameViewController()
@property (strong, nonatomic) CardMatchingGame *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@end

@implementation SetGameViewController

-(CardMatchingGame *)game
{
    if(!_game)
    {
        _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                  usingDeck:[[SetCardDeck alloc] init]
                                            andGameSettings:[[GameSettings alloc] initWithFlipCost:1 matchBonus:6 mismatchPenalty:2 andMatchMode:3]];
    }
    return _game;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // TODO: Move settings to an independent view controller where the user can change them at will.
    [AllGameSettings setSettings:[[GameSettings alloc] initWithFlipCost:1 matchBonus:6 mismatchPenalty:2 andMatchMode:3]forGame:@"SetGame"];
}

-(void)setCardButtons:(NSArray *)cardButtons
{
    _cardButtons = cardButtons;
    [self updateButtons];
}

-(UIColor *)translateColor:(int)color
{
    return color == 0 ? [UIColor blueColor] : (color == 1 ? [UIColor redColor] : [UIColor greenColor] );
}

-(float)translateShade:(int)shade
{
    return shade * 10;
}

#define FONT_SIZE 16
#define FONT_NAME @"Arial Rounded MT Bold"
-(void)updateButtons
{
    for(UIButton *cardButton in self.cardButtons)
    {
        SetCard *card = (SetCard *)[self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
        // Create attributed text to reflect this card and set it as the button's attributed title
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:card.description];
        NSRange range = NSMakeRange(0, [card.description length]);
        
        // Set attributes for normal "face-up" mode
        [attributedString setAttributes:
         @{NSFontAttributeName: [UIFont fontWithName:FONT_NAME size:FONT_SIZE],
            NSStrokeColorAttributeName : [self translateColor:card.color],
        NSForegroundColorAttributeName : [self translateColor:card.color],
            NSStrokeWidthAttributeName : @([self translateShade:card.shade])}
                                  range:range];
        [cardButton setAttributedTitle:attributedString forState:UIControlStateNormal];
        
        // Set attributes for selected mode
        if(card.isFaceUp)
        {
            [cardButton setBackgroundColor:[UIColor grayColor]];
        }
        else
        {
            [cardButton setBackgroundColor:nil];
        }
    }
}

@end
