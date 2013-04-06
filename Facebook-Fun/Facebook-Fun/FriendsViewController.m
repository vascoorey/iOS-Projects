//
//  HomeViewController.m
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/26/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "FriendsViewController.h"
#import "AppDelegate.h"
#import "CacheControl.h"
#import "NetworkActivity.h"

@interface FriendsViewController ()
@property (nonatomic) BOOL loginOK;
@end

@implementation FriendsViewController

-(void)setData:(NSArray *)data
{
    super.data = [data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[@"name"] compare:obj2[@"name"] options:NSCaseInsensitiveSearch];
    }];
}

-(IBAction)loginComplete:(UIStoryboardSegue *)segue
{
    self.loginOK = YES;
    // Check for cached results
    NSString *token = [[[FBSession activeSession] accessTokenData] accessToken];
    token = [token stringByAppendingString:@"-Friends"];
    NSData *data = [[CacheControl sharedControl] dataWithIdentifier:token];
    if(data)
    {
        NSLog(@"Got useful data from cache!");
        self.data = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        // Setup the query
        NSString *query =
        @"{"
        @"'friends':'SELECT uid2 FROM friend WHERE uid1 = me()',"
        @"'friendsInfo':'SELECT name, uid, pic_square FROM user WHERE uid IN (SELECT uid2 FROM #friends)',"
        @"}";
        [self executeFacebookQuery:query usingIndex:1];
    }
}

- (IBAction)logout:(id)sender {
    self.loginOK = NO;
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate closeSession];
    [self performSegueWithIdentifier:@"performLogin" sender:self];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!self.loginOK)
    {
        [self performSegueWithIdentifier:@"performLogin" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Friend";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    CFTimeInterval old = CACurrentMediaTime();
    // Configure the cell...
    // Get our friend's info
    // The dictionary keys are tied to the query (see above)
    NSDictionary *friendInfo = self.data[indexPath.row];
    NSString *urlString = friendInfo[@"pic_square"];
    NSString *identifier = [urlString lastPathComponent];
    __block NSData *pictureData = [[CacheControl sharedControl] dataWithIdentifier:identifier];
    
    cell.textLabel.text = friendInfo[@"name"];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", friendInfo[@"uid"]];
    cell.imageView.image = nil;
    
    dispatch_queue_t profileQ = dispatch_queue_create("Profile Picture Fetcher", NULL);
    dispatch_async(profileQ, ^{
        BOOL fetchedFromNetwork = NO;
        // Normal cache access time for profile pictures: 0.0001-0.0003s
        if(!pictureData)
        {
            [NetworkActivity addRequest];
            pictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            [NetworkActivity popRequest];
            fetchedFromNetwork = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(fetchedFromNetwork)
            {
                NSLog(@"Adding %@", identifier);
                [[CacheControl sharedControl] pushDataToCache:pictureData identifier:identifier];
            }
            if([[tableView indexPathsForVisibleRows] containsObject:indexPath])
            {
                UIImage *profilePicture = [UIImage imageWithData:pictureData];
                cell.imageView.image = profilePicture;
                [cell setNeedsLayout];
                if(fetchedFromNetwork)
                {
                    cell.imageView.alpha = 0.0f;
                    [UIView animateWithDuration:0.2f animations:^{
                        cell.imageView.alpha = 1.0f;
                    }];
                }
            }
            NSLog(@"Time: %g", CACurrentMediaTime() - old);
        });
    });
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if([sender isKindOfClass:[UITableViewCell class]])
    {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    if(indexPath)
    {
        if([segue.identifier isEqualToString:@"setFriendUID:"])
        {
            NSLog(@"setFriendUID:");
            NSNumber *friendUID = self.data[indexPath.row][@"uid"];
            if([segue.destinationViewController respondsToSelector:@selector(setFriendUID:)])
            {
                ((UIViewController *)segue.destinationViewController).title = ((UITableViewCell *)sender).textLabel.text;
                [segue.destinationViewController performSelector:@selector(setFriendUID:) withObject:friendUID];
            }
        }
    }
}

@end
