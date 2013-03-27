//
//  FriendDetailViewController.m
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/27/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "FriendDetailViewController.h"

@interface FriendDetailViewController ()

@end

@implementation FriendDetailViewController

-(void)setFriendUID:(NSNumber *)friendUID
{
    _friendUID = friendUID;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"setCVFriendUID:"] || [segue.identifier isEqualToString:@"setMVFriendUID:"])
    {
        NSLog(@"Segue: %@, %@", segue.identifier, self.friendUID);
        if([segue.destinationViewController respondsToSelector:@selector(setFriendUID:)])
        {
            [segue.destinationViewController performSelector:@selector(setFriendUID:) withObject:self.friendUID];
        }
    }
}

@end
