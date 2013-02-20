//
//  MatchismoViewController.m
//  Matchismo
//
//  Created by Vasco Orey on 2/1/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CardGameViewController.h"
#import "CardMatchingGame.h"
#import "GameResult.h"
#import "AllGameSettings.h"
#import <QuartzCore/QuartzCore.h>

@interface CardGameViewController () <UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (strong, nonatomic) CardMatchingGame *game;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionOfLastFlipLabel;
@property (weak, nonatomic) IBOutlet UISlider *historySlider;
@property (strong, nonatomic) GameResult *gameResult;
@property (weak, nonatomic) IBOutlet UICollectionView *cardCollectionView;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@end

@implementation CardGameViewController

-(void)setup
{
    [AllGameSettings setSettings:[self settings] forGame:self.gameName];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
}

-(void)awakeFromNib
{
    [self setup];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self setup];
    }
    return self;
}

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
        _game = [[CardMatchingGame alloc] initWithDeck:[self createDeck]
                                                  name:self.gameName];
    }
    return _game;
}

// Abstract
-(Deck *)createDeck
{
    NSAssert(false, @"createDeck must be overriden!");
    return nil;
}

// Abstract
-(GameSettings *)settings
{
    NSAssert(false, @"settings must be overriden!");
    return nil;
}

-(GameResult *)gameResult
{
    if(!_gameResult)
    {
        _gameResult = [[GameResult alloc] init];
    }
    return _gameResult;
}

-(void)updateDescriptionOfLastFlipLabel
{
    NSMutableAttributedString *attributedString = [self.descriptionOfLastFlipLabel.attributedText mutableCopy];
    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withString:self.game.descriptionOfLastFlip];
    self.descriptionOfLastFlipLabel.attributedText = attributedString;
}

-(void)updateUI
{
    for(UICollectionViewCell *cell in [self.cardCollectionView visibleCells])
    {
        NSIndexPath *indexPath = [self.cardCollectionView indexPathForCell:cell];
        Card *card = [self.game cardAtIndex:indexPath.item];
        [self updateCell:cell usingCard:card animate:YES];
    }
    [self updateDescriptionOfLastFlipLabel];
    self.historySlider.maximumValue = self.game.flipCount;
    self.historySlider.value = self.game.flipCount;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}

- (IBAction)flipCard:(UITapGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self.cardCollectionView];
    NSIndexPath *indexPath = [self.cardCollectionView indexPathForItemAtPoint:tapLocation];
    if(indexPath)
    {
        [self.game flipCardAtIndex:indexPath.item];
        self.gameResult.score = self.game.score;
        [self updateUI];
    }
}

- (IBAction)deal {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Dealing a new game will cancel the current game in progress." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        self.game = nil;
        self.gameResult = nil;
        [self.cardCollectionView reloadData];
        [self updateUI];
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

#pragma mark Collection View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [AllGameSettings settingsForGame:self.gameName].startingCardCount;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayingCard" forIndexPath:indexPath];
    Card *card = [self.game cardAtIndex:indexPath.item];
    [self updateCell:cell usingCard:card animate:NO];
    return cell;
}

-(void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card animate:(BOOL)animate
{
    NSAssert(false, @"updateCell must be overriden!");
}

@end
