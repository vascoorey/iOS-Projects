//
//  PhotosForTagCDTVC.m
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PhotosForTagCDTVC.h"
#import "Photo.h"
#import "FlickrFetcher.h"

@implementation PhotosForTagCDTVC

-(void)setTag:(Tag *)tag
{
    _tag = tag;
    self.title = _tag.name;
    [self setupFetchedResultsController];
}

-(void)setupFetchedResultsController
{
    if(self.tag.managedObjectContext)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY tags = %@", self.tag];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.tag.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    }
    else
    {
        self.fetchedResultsController = nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo"];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    dispatch_queue_t thumbnailQ = dispatch_queue_create("Thumbnail Fetcher", NULL);
    dispatch_async(thumbnailQ, ^{
        // Download the photo's thumbnail
        if(!photo.thumbnail)
        {
            photo.thumbnail = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
        }
        UIImage *thumbnailImage = [UIImage imageWithData:photo.thumbnail];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = thumbnailImage;
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
        if([segue.identifier isEqualToString:@"setImageURL:"])
        {
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if([segue.destinationViewController respondsToSelector:@selector(setImageURL:)])
            {
                [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
            }
        }
    }
}


@end
