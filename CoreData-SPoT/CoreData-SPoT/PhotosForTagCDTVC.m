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
#import "NetworkActivity.h"

@implementation PhotosForTagCDTVC

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.shouldMarkAccessDate = YES;
}

-(void)setTag:(Tag *)tag
{
    _tag = tag;
    self.title = [_tag.name capitalizedString];
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


@end
