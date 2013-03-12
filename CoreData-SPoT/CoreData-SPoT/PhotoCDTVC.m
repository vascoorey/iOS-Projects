//
//  PhotoCDTVC.m
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PhotoCDTVC.h"
#import "Photo.h"
#import "NetworkActivity.h"

@implementation PhotoCDTVC

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo"];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    if(photo.thumbnail)
    {
        cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:photo.thumbnailURL];
        dispatch_queue_t thumbnailQ = dispatch_queue_create("Thumbnail Fetcher", NULL);
        dispatch_async(thumbnailQ, ^{
            // Download the photo's thumbnail
            [NetworkActivity addRequest];
            NSData *thumbnail = [[NSData alloc] initWithContentsOfURL:url];
            [NetworkActivity removeRequest];
            UIImage *thumbnailImage = [UIImage imageWithData:photo.thumbnail];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Should only access CoreData in the main thread
                photo.thumbnail = thumbnail;
                cell.imageView.image = thumbnailImage;
                [cell setNeedsDisplay];
            });
        });
    }
    
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
        if([segue.identifier isEqualToString:@"setImageURL:"])
        {
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if(self.shouldMarkAccessDate)
            {
                NSLog(@"Previous access: %@", photo.viewed);
                photo.viewed = [NSDate date];
                NSLog(@"Last access for %@: %@", photo.unique, photo.viewed);
            }
            if([segue.destinationViewController respondsToSelector:@selector(setImageURL:)])
            {
                [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
            }
        }
    }
}

@end
