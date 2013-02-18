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

#define FONT_SIZE 17
#define FONT_NAME @"Arial Rounded MT Bold"
#define BUTTON_ALPHA 0.167f

@interface SetGameViewController()
@property (strong, nonatomic) CardMatchingGame *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (weak, nonatomic) IBOutlet UILabel *descriptionOfLastFlipLabel;
@end

@implementation SetGameViewController

-(CardMatchingGame *)game
{
    if(!_game)
    {
        _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                  usingDeck:[[SetCardDeck alloc] init]
                                            andGameSettings:[[GameSettings alloc] initWithFlipCost:1 matchBonus:6 mismatchPenalty:2 matchMode:3 shouldRedealCards:YES]];
    }
    return _game;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // TODO: Move settings to an independent view controller where the user can change them at will.
    // [AllGameSettings setSettings:[[GameSettings alloc] initWithFlipCost:1 matchBonus:6 mismatchPenalty:2 matchMode:3 redrawCards:YES]forGame:@"SetGame"];
}

-(void)setCardButtons:(NSArray *)cardButtons
{
    _cardButtons = cardButtons;
    [self updateButtons];
}

-(void)updateDescriptionOfLastFlipLabel
{
    NSMutableAttributedString *attributedString = [self.descriptionOfLastFlipLabel.attributedText mutableCopy];
    [attributedString replaceCharactersInRange:NSMakeRange(0, [attributedString string].length) withString:self.game.descriptionOfLastFlip];
    for(SetCard *card in self.game.cardsForLastFlip)
    {
        NSRange range = [[attributedString string] rangeOfString:[NSString stringWithFormat:@" %@ ", card.description]];
        // Set attributes for normal "face-up" mode
        [attributedString setAttributes:
         @{NSStrokeColorAttributeName : [self strokeColorForCard:card],
        NSForegroundColorAttributeName : [self foregroundColorForCard:card],
            NSStrokeWidthAttributeName : @(-10)}
                                  range:range];
    }
    self.descriptionOfLastFlipLabel.attributedText = attributedString;
}

-(UIColor *)strokeColorForCard:(SetCard *)card
{
    return card.color == 1 ? [UIColor blueColor]
                      : (card.color == 2 ? [UIColor redColor]
                                    : [UIColor greenColor] );
}

-(UIColor *)foregroundColorForCard:(SetCard *)card
{
    return [[self strokeColorForCard:card] colorWithAlphaComponent:card.shadeValue];
}

-(NSMutableAttributedString *)setAttributes:(NSMutableAttributedString *)attributedString forCard:(SetCard *)card withRange:(NSRange)range
{
    
    return attributedString;
}

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
            NSStrokeColorAttributeName : [self strokeColorForCard:card],
        NSForegroundColorAttributeName : [self foregroundColorForCard:card],
            NSStrokeWidthAttributeName : @(-10)}
                                  range:range];
        [cardButton setAttributedTitle:attributedString forState:UIControlStateNormal];
        if(card.isFaceUp)
        {
            [cardButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:BUTTON_ALPHA]];
        }
        else
        {
            [cardButton setBackgroundColor:nil];
        }
        cardButton.enabled = !card.isUnplayable;
        if(!cardButton.enabled)
        {
            //NSLog(@"%d : %@", cardButton.state, card.description);
            [cardButton setBackgroundColor:nil];
            [cardButton setAttributedTitle:nil forState:UIControlStateSelected|UIControlStateDisabled];
            [cardButton setAttributedTitle:nil forState:UIControlStateNormal];
            //[cardButton setAttributedTitle:nil forState:UIControlStateNormal|UIControlStateDisabled];
        }
    }
}

@end
