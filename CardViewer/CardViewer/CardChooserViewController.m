//
//  CardChooserViewController.m
//  CardViewer
//
//  Created by Vasco Orey on 2/20/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CardChooserViewController.h"
#import "CardDisplayViewController.h"

@interface CardChooserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *suitSegmentedControl;
@property (nonatomic) NSUInteger rank;
@property (readonly, nonatomic) NSString *suit;
@end

@implementation CardChooserViewController

-(NSString *)rankAsString
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"][self.rank];
}

-(void)setRank:(NSUInteger)rank
{
    _rank = rank;
    self.rankLabel.text = [self rankAsString];
}

-(NSString *)suit
{
    return [self.suitSegmentedControl titleForSegmentAtIndex:self.suitSegmentedControl.selectedSegmentIndex];
}

- (IBAction)changeRank:(UISlider *)sender
{
    self.rank = roundf(sender.value);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowCard"])
    {
        if([segue.destinationViewController isKindOfClass:[CardDisplayViewController class]])
        {
            CardDisplayViewController *cardDisplayViewController = (CardDisplayViewController *)segue.destinationViewController;
            cardDisplayViewController.suit = self.suit;
            cardDisplayViewController.rank = self.rank;
            cardDisplayViewController.title = [NSString stringWithFormat:@"%d %@", self.rank, self.suit];
        }
    }
}

@end
