//
//  MRTViewController.h
//  MagicalRecordTest
//
//  Created by Vasco Orey on 5/9/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end
