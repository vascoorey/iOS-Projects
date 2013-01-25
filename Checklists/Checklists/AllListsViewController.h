//
//  AllListsViewController.h
//  Checklists
//
//  Created by Vasco Orey on 1/24/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListDetailViewController.h"

@interface AllListsViewController : UITableViewController <ListDetailViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *lists;

@end
