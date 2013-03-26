//
//  FriendsTableViewController.h
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/23/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookTableViewController : UITableViewController

// The result of the facebook query
@property (nonatomic, strong) NSArray *data;

// If using a multi query
-(void)executeFacebookQuery:(NSString *)query usingIndex:(NSUInteger)index;
// If using single query
-(void)executeFacebookQuery:(NSString *)query;

@end
