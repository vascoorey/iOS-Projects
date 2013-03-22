//
//  KitchenSinkViewController.m
//  Kitchen-Sink
//
//  Created by Vasco Orey on 3/15/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "KitchenSinkViewController.h"
#import "AskerViewController.h"

@interface KitchenSinkViewController ()
@property (weak, nonatomic) IBOutlet UIView *kitchenSink;
@property (weak, nonatomic) NSTimer *drainTimer;
@property (weak, nonatomic) NSTimer *gameTimer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scoreButtonItem;
@property (nonatomic) NSUInteger score;
@end

@implementation KitchenSinkViewController

#define MOVE_DURATION 2.0f
#define DRAIN_DURATION 2.0f
#define DRAIN_DELAY 0.0f
#define DISH_CLEANING_INTERVAL 2.0f
#define GAME_DURATION 30.0f

-(void)cleanDish
{
    if(self.kitchenSink.window)
    {
        [self addFood:nil];
        [self performSelector:@selector(cleanDish) withObject:nil afterDelay:DISH_CLEANING_INTERVAL];
    }
}

-(void)startDrainTimer
{
    self.drainTimer = [NSTimer scheduledTimerWithTimeInterval:DRAIN_DURATION/3 target:self selector:@selector(drain:) userInfo:nil repeats:YES];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:GAME_DURATION target:self selector:@selector(gameOver:) userInfo:nil repeats:NO];
}

-(void)stopDrainTimer
{
    [self.drainTimer invalidate];
    [self.gameTimer invalidate];
    self.drainTimer = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startDrainTimer];
    [self cleanDish];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopDrainTimer];
}

- (IBAction)restart:(id)sender {
    self.scoreButtonItem.title = @"Points: 0";
    self.score = 0;
    [self startDrainTimer];
}

- (IBAction)tap:(UITapGestureRecognizer *)sender {
    CGPoint tapLocation = [sender locationInView:self.kitchenSink];
    for(UIView *view in self.kitchenSink.subviews)
    {
        if(CGRectContainsPoint(view.frame, tapLocation))
        {
            [UIView animateWithDuration:MOVE_DURATION
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [self setRandomLocationForView:view];
                                 view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.99, 0.99);
                             }
                             completion:^(BOOL success){
                                 view.transform = CGAffineTransformIdentity;
                             }];
        }
    }
}

-(void)drain:(NSTimer *)timer
{
    [self drain];
}

-(void)gameOver:(NSTimer *)timer
{
    [self stopDrainTimer];
    for(UIView *view in self.kitchenSink.subviews)
    {
        [view removeFromSuperview];
    }
    NSString *score = [NSString stringWithFormat:@"Way to go champ! You only lost %d foods!", self.score];
    [[[UIAlertView alloc] initWithTitle:@"Game Over!" message:score delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil] show];
}

-(IBAction)drain
{
    for(UIView *view in self.kitchenSink.subviews)
    {
        CGAffineTransform transform = view.transform;
        if(CGAffineTransformIsIdentity(transform))
        {
            [UIView animateWithDuration:DRAIN_DURATION
                                  delay:DRAIN_DELAY
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.7, 0.7), 2*M_PI/3);
                             }
                             completion:^(BOOL success){
                                 if(success)
                                 {
                                     [UIView animateWithDuration:DRAIN_DURATION
                                                           delay:DRAIN_DELAY
                                                         options:UIViewAnimationOptionCurveLinear
                                                      animations:^{
                                                          view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.4, 0.4), -2*M_PI/3);
                                                      }
                                                      completion:^(BOOL success){
                                                          if(success)
                                                          {
                                                              [UIView animateWithDuration:DRAIN_DURATION
                                                                                    delay:DRAIN_DELAY
                                                                                  options:UIViewAnimationOptionCurveLinear
                                                                               animations:^{
                                                                                   view.transform = CGAffineTransformScale(transform, 0.1, 0.1);
                                                                               }
                                                                               completion:^(BOOL success){
                                                                                   if(success)
                                                                                   {
                                                                                       self.score ++;
                                                                                       self.scoreButtonItem.title = [NSString stringWithFormat:@"Points: %d", self.score];
                                                                                       [view removeFromSuperview];
                                                                                   }
                                                                               }];
                                                          }
                                                      }];
                                 }
                             }];
        }
    }
}

-(void)addFood:(NSString *)food
{
    UILabel *foodLabel = [[UILabel alloc] init];
    
#define BLUE_FOOD @"Jello"
#define GREEN_FOOD @"Broccolli"
#define ORANGE_FOOD @"Carrot"
#define RED_FOOD @"Red Pepper"
#define PURPLE_FOOD @"Eggplant"
#define BROWN_FOOD @"Potato Peels"
    
    static NSDictionary *foods = nil;
    if(!foods)
    {
        foods = @{ BLUE_FOOD : [UIColor blueColor],
                   GREEN_FOOD : [UIColor greenColor],
                   ORANGE_FOOD : [UIColor orangeColor],
                   RED_FOOD : [UIColor redColor],
                   PURPLE_FOOD : [UIColor purpleColor],
                   BROWN_FOOD : [UIColor brownColor] };
    }
    
    if(![food length])
    {
        food = [[foods allKeys] objectAtIndex:arc4random() % [foods count]];
        foodLabel.textColor = foods[food];
    }
    
    foodLabel.text = food;
    foodLabel.font = [UIFont systemFontOfSize:46];
    foodLabel.backgroundColor = [UIColor clearColor];
    [self setRandomLocationForView:foodLabel];
    [self.kitchenSink addSubview:foodLabel];
}

-(void)setRandomLocationForView:(UIView *)view
{
    [view sizeToFit]; // Views with intrinsic size can do this
    CGRect sinkBounds = CGRectInset(self.kitchenSink.bounds, view.frame.size.width / 2, view.frame.size.height / 2);
    CGFloat x = arc4random() % (int)sinkBounds.size.width + view.frame.size.width / 2;
    CGFloat y = arc4random() % (int)sinkBounds.size.height + view.frame.size.height / 2;
    view.center = CGPointMake(x, y);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Ask"])
    {
        AskerViewController *asker = segue.destinationViewController;
        asker.question = @"What food do you want in the sink?";
    }
}

-(IBAction)cancelAsking:(UIStoryboardSegue *)segue
{
    
}

-(IBAction)doneAsking:(UIStoryboardSegue *)segue
{
    AskerViewController *asker = segue.sourceViewController;
    [self addFood:asker.answer];
}
@end
