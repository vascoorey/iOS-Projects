//
//  DemoPhotographerCDTVC.m
//  Photomania
//
//  Created by Vasco Orey on 3/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DemoPhotographerCDTVC.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"

@implementation DemoPhotographerCDTVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.managedObjectContext)
    {
        NSLog(@"Using demo document");
        [self useDemoDocument];
    }
    else
    {
        NSLog(@"Already have a managed object context");
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

-(IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *photos = [FlickrFetcher latestGeoreferencedPhotos];
        // Put the photos in CoreData
        [self.managedObjectContext performBlock:^{
            for(NSDictionary *photo in photos)
            {
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

-(void)useDemoDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Demo"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        NSLog(@"Creating the demo document (%@)", [url path]);
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success)
            {
                self.managedObjectContext = document.managedObjectContext;
                [self refresh];
            }
            else
            {
                NSLog(@"Could not create the document at %@", url);
            }
        }];
    }
    else if(document.documentState == UIDocumentStateClosed)
    {
        [document openWithCompletionHandler:^(BOOL success) {
            if(success)
            {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    }
    else
    {
        self.managedObjectContext = document.managedObjectContext;
    }
}

@end
