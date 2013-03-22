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
@end

@implementation KitchenSinkViewController

#define MOVE_DURATION 2.00f
#define DRAIN_DURATION 2.00f
#define DRAIN_DELAY 0.00f

-(void)startDrainTimer
{
    self.drainTimer = [NSTimer scheduledTimerWithTimeInterval:DRAIN_DURATION/3 target:self selector:@selector(drain:) userInfo:nil repeats:YES];
}

-(void)stopDrainTimer
{
    [self.drainTimer invalidate];
    self.drainTimer = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startDrainTimer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopDrainTimer];
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
    NSLog(@"Draining...");
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
