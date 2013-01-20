//
//  BullsEyeViewController.h
//  BullsEye
//
//  Created by Vasco Orey on 1/19/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BullsEyeViewController : UIViewController

@property int currentValue;

-(IBAction)showAlert;
-(IBAction)sliderMoved:(UISlider *)slider;

@end
