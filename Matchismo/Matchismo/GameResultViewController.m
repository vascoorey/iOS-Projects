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

-(void)updateUISorted:(BOOL)sorted withSelector:(SEL)selector
{
    NSArray *allGameResults = [GameResult allGameResults];
    if(sorted)
    {
        allGameResults = [allGameResults sortedArrayUsingSelector:selector];
    }
    NSString *resultsText = @"";
    for(GameResult *result in allGameResults)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        resultsText = [resultsText stringByAppendingFormat:@"Score: %d (Start: %@, Duration: %0g seconds)\n", result.score, [formatter stringFromDate:result.start], round(result.duration)];
    }
    self.display.text = resultsText;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUISorted:NO withSelector:nil];
}

- (IBAction)sortByDuration {
    [self updateUISorted:YES withSelector:@selector(compareByDuration:)];
}

- (IBAction)sortByScore {
    [self updateUISorted:YES withSelector:@selector(compareByScore:)];
}

- (IBAction)sortByDate {
    [self updateUISorted:YES withSelector:@selector(compareByDate:)];
}

@end
