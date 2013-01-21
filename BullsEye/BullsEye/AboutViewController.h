//
//  AboutViewController.h
//  BullsEye
//
//  Created by Vasco Orey on 1/20/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIWebView *webView;

-(IBAction)close;

@end
