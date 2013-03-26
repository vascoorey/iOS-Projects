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

// Will execute the given facebook query (or multiquery)
//  and set the instance's data property to the array at the given index.
//
// For example, with the query and index 1:
//  @"{"
//  @"'friends':'SELECT uid2 FROM friend WHERE uid1 = me()',"
//  @"'friendsInfo':'SELECT name, uid, pic_square FROM user WHERE uid IN (SELECT uid2 FROM #friends)',"
//  @"}";
// will set the result of the 'friends' query to the data property and reload the tableView.
-(void)executeFacebookQuery:(NSString *)query usingIndex:(NSUInteger)index;
// If using single query
-(void)executeFacebookQuery:(NSString *)query;

@end
