//
//  GameResultViewController.m
//  Matchismo
//
//  Created by Vasco Orey on 2/9/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "GameResultViewController.h"
#import "GameResult.h"

@interface GameResultViewController ()
@property (weak, nonatomic) IBOutlet UITextView *display;

@end

@implementation GameResultViewController

-(void)setup
{
    // Anything that has to be setup before viewDidLoad
}

-(void)awakeFromNib
{
    [self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setup];
    }
    return self;
}

-(void)updateUI
{
    NSString *resultsText = @"";
    for(GameResult *result in [GameResult allGameResults])
    {
        NSLog(@"Hail mary");
        resultsText = [resultsText stringByAppendingFormat:@"Score: %d (Start: %@, End: %@, Duration: %0g\n", result.score, result.start, result.end, result.duration];
    }
    self.display.text = resultsText;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
}

@end
