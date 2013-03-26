//
//  AppDelegate.h
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/26/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
-(void)closeSession;

@end
