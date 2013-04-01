//
//  FriendsTableViewController.m
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/23/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "FacebookTableViewController.h"
#import "SVProgressHUD.h"
#import "NetworkActivity.h"
#import "CacheControl.h"

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

-(void)executeFacebookQuery:(NSString *)query usingIndex:(NSUInteger)index
{
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q" : query };
    CFTimeInterval old = CACurrentMediaTime();
    [SVProgressHUD showWithStatus:@"Fetching Data..." maskType:SVProgressHUDMaskTypeGradient];
    [NetworkActivity addRequest];
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              NSLog(@"Time taken for query: %g", CACurrentMediaTime() - old);
                              [SVProgressHUD popActivity];
                              [NetworkActivity popRequest];
                              if (error) {
                                  NSLog(@"Error: %@", error);
                              } else {
                                  [[CacheControl sharedControl] pushDataToCache:[NSKeyedArchiver archivedDataWithRootObject:result[@"data"][index][@"fql_result_set"]]
                                                                      identifier:[[[[FBSession activeSession] accessTokenData] accessToken] stringByAppendingString:@"-Friends"]
                                                                      expiration:[[NSDate date] dateByAddingTimeInterval:24*60*60]];
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
    NSAssert(false, @"You must subclass this class and implement tableView:cellForRowAtIndexPath:");
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.data count];
}

@end
