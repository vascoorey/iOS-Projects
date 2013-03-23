//
//  KitchenSinkViewController.m
//  Kitchen-Sink
//
//  Created by Vasco Orey on 3/15/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "KitchenSinkViewController.h"
#import "AskerViewController.h"
#import "CMMotionManager+Shared.h"

@interface KitchenSinkViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *kitchenSink;
@property (weak, nonatomic) NSTimer *drainTimer;
@property (weak, nonatomic) NSTimer *gameTimer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scoreButtonItem;
@property (nonatomic) NSUInteger score;
@property (weak, nonatomic) UIActionSheet *sinkControlActionSheet;
@property (strong, nonatomic) UIPopoverController *imagePickerPopover;
@end

@implementation KitchenSinkViewController

#pragma mark - Timers

#define MOVE_DURATION 2.0f
#define DRAIN_DURATION 2.0f
#define DRAIN_DELAY 0.0f
#define DISH_CLEANING_INTERVAL 2.0f
#define GAME_DURATION 30.0f
#define MAX_IMAGE_WIDTH 200

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

#pragma mark - View Lifecycle

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startDrainTimer];
    [self cleanDish];
    [self startDrift];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopDrainTimer];
    [self stopDrift];
}

#pragma mark - Drift

#define DRIFT_HZ 10
#define DRIFT_RATE 1

-(void)startDrift
{
    CMMotionManager *motionManager = [CMMotionManager sharedMotionManager];
    if([motionManager isAccelerometerAvailable])
    {
        [motionManager setAccelerometerUpdateInterval:1 / DRIFT_HZ];
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            for(UIView *view in self.kitchenSink.subviews)
            {
                CGPoint centerPoint = view.center;
                centerPoint.x += accelerometerData.acceleration.x * DRIFT_RATE;
                centerPoint.y -= accelerometerData.acceleration.y * DRIFT_RATE;
                view.center = centerPoint;
                if(!CGRectContainsRect(self.kitchenSink.bounds, view.frame) && !CGRectIntersectsRect(self.kitchenSink.bounds, view.frame))
                {
                    [view removeFromSuperview];
                }
            }
        }];
    }
}

-(void)stopDrift
{
    [[CMMotionManager sharedMotionManager] stopAccelerometerUpdates];
}

#pragma mark - Action Sheet

#define SINK_CONTROL @"Sink Controls"
#define SINK_CONTROL_STOP_DRAIN @"Stopper Drain"
#define SINK_CONTROL_UNSTOP_DRAIN @"Unstopper Drain"
#define SINK_CONTROL_CANCEL @"Cancel"
#define SINK_CONTROL_EMPTY @"Empty Sink"

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.destructiveButtonIndex)
    {
        [self.kitchenSink.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    else
    {
        NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([choice isEqualToString:SINK_CONTROL_STOP_DRAIN])
        {
            [self stopDrainTimer];
        }
        else
        {
            [self startDrainTimer];
        }
    }
}

- (IBAction)controlSink:(UIBarButtonItem *)sender {
    if(!self.sinkControlActionSheet)
    {
        NSString *drainButton = self.drainTimer ? SINK_CONTROL_STOP_DRAIN : SINK_CONTROL_UNSTOP_DRAIN;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:SINK_CONTROL
                                                                 delegate:self
                                                        cancelButtonTitle:SINK_CONTROL_CANCEL
                                                   destructiveButtonTitle:SINK_CONTROL_EMPTY
                                                        otherButtonTitles:drainButton, nil];
        [actionSheet showFromBarButtonItem:sender animated:YES];
        self.sinkControlActionSheet = actionSheet;
    }
}

#pragma mark - Image Picker

-(void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType sender:(UIBarButtonItem *)sender
{
    if(!self.imagePickerPopover && [UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        if([availableMediaTypes containsObject:(NSString *)kUTTypeImage])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = sourceType;
            picker.mediaTypes = @[ (NSString *)kUTTypeImage ];
            picker.allowsEditing = YES;
            picker.delegate = self;
            if((sourceType != UIImagePickerControllerSourceTypeCamera) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
            {
                // Popover
                self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
                [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                self.imagePickerPopover.delegate = self;
            }
            else
            {
                // Modal
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
    }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePickerPopover = nil;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss modal
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if(!image)
    {
        image = info[UIImagePickerControllerOriginalImage];
    }
    if(image)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGRect frame = imageView.frame;
        if(frame.size.width > MAX_IMAGE_WIDTH)
        {
            frame.size.height = (frame.size.height / frame.size.width) * MAX_IMAGE_WIDTH;
            frame.size.width = MAX_IMAGE_WIDTH;
        }
        imageView.frame = frame;
        [self setRandomLocationForView:imageView];
        [self.kitchenSink addSubview:imageView];
    }
    if(self.imagePickerPopover)
    {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    }
    else
    {
        // Dismiss modal
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)takeFoodPhoto:(UIBarButtonItem *)sender {
    [self presentImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum sender:sender];
}

- (IBAction)addFoodPhoto:(UIBarButtonItem *)sender {
    [self presentImagePicker:UIImagePickerControllerSourceTypeCamera sender:sender];
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

-(void)gameOver:(NSTimer *)timer
{
    [self stopDrainTimer];
    [self.kitchenSink.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSString *score = [NSString stringWithFormat:@"Way to go champ! You only lost %d foods!", self.score];
    [[[UIAlertView alloc] initWithTitle:@"Game Over!" message:score delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil] show];
}

- (IBAction)restart:(id)sender {
    self.scoreButtonItem.title = @"Points: 0";
    self.score = 0;
    [self startDrainTimer];
}

#pragma mark View Animation

-(void)drain:(NSTimer *)timer
{
    [self drain];
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
    [foodLabel sizeToFit]; // Views with intrinsic size can do this
    [self setRandomLocationForView:foodLabel];
    [self.kitchenSink addSubview:foodLabel];
}

-(void)setRandomLocationForView:(UIView *)view
{
    CGRect sinkBounds = CGRectInset(self.kitchenSink.bounds, view.frame.size.width / 2, view.frame.size.height / 2);
    CGFloat x = arc4random() % (int)sinkBounds.size.width + view.frame.size.width / 2;
    CGFloat y = arc4random() % (int)sinkBounds.size.height + view.frame.size.height / 2;
    view.center = CGPointMake(x, y);
}

#pragma mark - Segue

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
