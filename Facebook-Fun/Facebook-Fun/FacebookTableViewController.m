//
//  FriendsTableViewController.m
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/23/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "FacebookTableViewController.h"
#import "SVProgressHUD.h"

@interface FacebookTableViewController ()
@end

@implementation FacebookTableViewController

-(void)setData:(NSArray *)data
{
    _data = data;
    // Datasource has been changed: reload data !
    [self.tableView reloadData];
}

#pragma mark - Facebook

// Will execute the given facebook query (or multiquery)
//  and set the instance's data property to the array at the given index.
//
// For example, with the query and index 1:
//  @"{"
//  @"'friends':'SELECT uid2 FROM friend WHERE uid1 = me()',"
//  @"'friendsInfo':'SELECT name, uid, pic_square FROM user WHERE uid IN (SELECT uid2 FROM #friends)',"
//  @"}";
// will set the result of the 'friends' query to the data property and reload the tableView.
-(void)executeFacebookQuery:(NSString *)query usingIndex:(NSUInteger)index
{
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q" : query };
    CFTimeInterval old = CACurrentMediaTime();
    [SVProgressHUD showWithStatus:@"Fetching Data..." maskType:SVProgressHUDMaskTypeGradient];
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              NSLog(@"Time taken for query: %g", CACurrentMediaTime() - old);
                              [SVProgressHUD popActivity];
                              if (error) {
                                  NSLog(@"Error: %@", error);
                              } else {
                                  self.data = result[@"data"][index][@"fql_result_set"];
                              }
                          }];
}

-(void)executeFacebookQuery:(NSString *)query
{
    [self executeFacebookQuery:query usingIndex:0];
}

#pragma mark - Init & View Lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(false, @"You must subclass this class and implement tableView:cellForRowAtIndexPath: as I have no idea what self.data has!");
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.data count];
}

@end
