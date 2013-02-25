//
//  StanfordPhotosTVC.m
//  SPoT
//
//  Created by Vasco Orey on 2/25/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "StanfordPhotosTVC.h"
#import "Utils.h"
#import "FlickrFetcher.h"

@interface StanfordPhotosTVC ()

@end

@implementation StanfordPhotosTVC

-(void)didSelectPhoto:(NSDictionary *)photo
{
    NSMutableArray *recents = [[[NSUserDefaults standardUserDefaults] objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if(!recents)
    {
        recents = [[NSMutableArray alloc] init];
    }
    if([recents containsObject:photo])
    {
        [recents removeObject:photo];
    }
    [recents addObject:photo];
    while([recents count] > MAX_RECENT_PHOTOS)
    {
        [recents removeLastObject];
    }
    [[NSUserDefaults standardUserDefaults] setObject:recents forKey:RECENT_PHOTOS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // What we need to do here is find out what photo is going to be shown and add it to the recent photos
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            [self didSelectPhoto:self.photos[indexPath.row]];
        }
    }
    [super prepareForSegue:segue sender:sender];
}

@end
