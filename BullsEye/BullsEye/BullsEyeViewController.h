//
//  BullsEyeViewController.h
//  BullsEye
//
//  Created by Vasco Orey on 1/19/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BullsEyeViewController : UIViewController <UIAlertViewDelegate>

@property int targetValue;
@property int score;
@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet UILabel *targetLabel;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *roundLabel;

-(IBAction)showAlert;
-(IBAction)reset;
-(IBAction)showInfo;

@end
