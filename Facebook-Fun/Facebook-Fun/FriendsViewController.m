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

@interface FriendsViewController ()
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
    // Setup the query
    NSString *query =
    @"{"
    @"'friends':'SELECT uid2 FROM friend WHERE uid1 = me()',"
    @"'friendsInfo':'SELECT name, uid, pic_square FROM user WHERE uid IN (SELECT uid2 FROM #friends)',"
    @"}";
    [self executeFacebookQuery:query usingIndex:1];
}

- (IBAction)logout:(id)sender {
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

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self performSegueWithIdentifier:@"performLogin" sender:self];
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
    
    // Configure the cell...
    // Get our friend's info
    // The dictionary keys are tied to the query (see above)
    NSDictionary *friendInfo = self.data[indexPath.row];
    cell.textLabel.text = friendInfo[@"name"];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", friendInfo[@"uid"]];
    cell.imageView.image = nil;
    
    dispatch_queue_t profileQ = dispatch_queue_create("Profile Picture Fetcher", NULL);
    dispatch_async(profileQ, ^{
        NSData *pictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:friendInfo[@"pic_square"]]];
        UIImage *profilePicture = [UIImage imageWithData:pictureData];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = profilePicture;
            [cell setNeedsLayout];
            cell.imageView.alpha = 0.0f;
            [UIView animateWithDuration:0.2f animations:^{
                cell.imageView.alpha = 1.0f;
            }];
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
