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

-(void)userCheatedSoUpdateCell:(UICollectionViewCell *)cell
{
    NSAssert(false, @"userCheatedSoUpdateCell: must be overidden!");
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
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.game.score];
    if(self.game.hasUnplayableCards)
    {
        [self removeUnplayableCards];
    }
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

- (IBAction)findMatch {
    dispatch_queue_t cheatQ = dispatch_queue_create("Cheating Queue", NULL);
    dispatch_async(cheatQ, ^{
        NSArray *indices = [self.game indicesForMatch];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(indices)
            {
                [self getCellsAndUpdateAtIndices:indices];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Oops!"
                                            message:@"No matches left... Maybe draw some more cards?"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        });
    });
}

-(void)getCellsAndUpdateAtIndices:(NSArray *)indices
{
    for(id index in indices)
    {
        NSAssert([index isKindOfClass:[NSNumber class]], @"Bad NSArray: contained non-NSNumbers!");
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:((NSNumber *)index).unsignedIntValue inSection:0];
        UICollectionViewCell *cell = [self.cardCollectionView cellForItemAtIndexPath:indexPath];
        [self userCheatedSoUpdateCell:cell];
        [self.cardCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
}

#pragma mark Collection View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.game.cardsInPlay;
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

-(IBAction)dealMoreCards
{
    dispatch_queue_t cheatQ = dispatch_queue_create("Cheating Queue", NULL);
    dispatch_async(cheatQ, ^{
        NSArray *indices = [self.game requestCards:self.cardsToAdd];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([indices count])
            {
                NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                for(NSNumber *index in indices)
                {
                    [indexPaths addObject:[NSIndexPath indexPathForItem:index.unsignedIntegerValue inSection:0]];
                }
                // Reload data for the collection view...
                [self.cardCollectionView insertItemsAtIndexPaths:indexPaths];
                [self.cardCollectionView scrollToItemAtIndexPath:[indexPaths lastObject] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"No more cards!" message:@"If you want to play with a new deck go ahead and press Deal!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            if(self.game.hadMatch)
            {
                [self updateUI];
                [[[UIAlertView alloc] initWithTitle:@"Missed a match" message:@"You missed a match!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        });
    });
}

-(void)removeUnplayableCards
{
    NSArray *indices = [self.game removeUnplayableCards];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    if([indices count])
    {
        for(NSNumber *index in indices)
        {
            [indexPaths addObject:[NSIndexPath indexPathForItem:index.unsignedIntegerValue inSection:0]];
        }
        [self.cardCollectionView deleteItemsAtIndexPaths:indexPaths];
    }
}

@end
