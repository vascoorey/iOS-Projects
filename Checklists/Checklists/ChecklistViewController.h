//
//  ChecklistsViewController.h
//  Checklists
//
//  Created by Vasco Orey on 1/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemDetailViewController.h"
#import "Checklist.h"

@interface ChecklistViewController : UITableViewController <ItemDetailControllerDelegate>

@property (nonatomic, strong) Checklist *checklist;

@end
