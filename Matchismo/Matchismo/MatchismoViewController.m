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
#import "CardMatchingGame.h"

@interface MatchismoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (strong, nonatomic) CardMatchingGame *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionOfLastFlipLabel;
@property (weak, nonatomic) IBOutlet UISwitch *matchModeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *matchModeLabel;
@property (weak, nonatomic) IBOutlet UISlider *historySlider;
@end

@implementation MatchismoViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.historySlider.maximumValue = self.game.flipCount;
    self.historySlider.value = self.game.flipCount;
    [self updateUI];
}

-(CardMatchingGame *)game
{
    if(!_game)
    {
        _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                  usingDeck:[[PlayingCardDeck alloc] init]];
    }
    return _game;
}

-(void)setCardButtons:(NSArray *)cardButtons
{
    _cardButtons = cardButtons;
    for(UIButton *button in self.cardButtons)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"Card_0.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"Card_1.png"] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:@"Card_1.png"] forState:UIControlStateSelected|UIControlStateDisabled];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, CGRectGetHeight(button.frame), 0, 0)];
    }
    [self updateUI];
}

-(void)updateUI
{
    for(UIButton *cardButton in self.cardButtons)
    {
        Card *card = [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
        [cardButton setTitle:card.contents forState:UIControlStateSelected];
        [cardButton setTitle:card.contents forState:UIControlStateSelected|UIControlStateDisabled];
        cardButton.selected = card.isFaceUp;
        cardButton.enabled = !card.isUnplayable;
        cardButton.alpha = card.isUnplayable ? 0.5 : 1.0;
    }
    self.historySlider.maximumValue = self.game.flipCount;
    self.historySlider.value = self.game.flipCount;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
    self.descriptionOfLastFlipLabel.text = self.game.descriptionOfLastFlip;
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.game.flipCount];
}

- (IBAction)flipCard:(UIButton *)sender {
    self.matchModeSwitch.enabled = NO;
    [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
    [self updateUI];
}

- (IBAction)deal {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Dealing a new game will cancel the current game in progress." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        self.matchModeSwitch.enabled = YES;
        [self.game reset];
        [self updateUI];
    }
}

- (IBAction)switchPlayingMode {
    [self.game switchMatchingMode];
    if(self.matchModeSwitch.isOn)
    {
        self.matchModeLabel.text = @"2 Card Match";
    }
    else
    {
        self.matchModeLabel.text = @"3 Card Match";
    }
}

- (IBAction)showHistory:(UISlider *)sender
{
    NSInteger flipToShow = roundf(sender.value);
    NSString *flipDescription = [self.game descriptionOfFlip:flipToShow];
    if(flipDescription)
    {
        self.descriptionOfLastFlipLabel.text = flipDescription;
    }
}

@end
