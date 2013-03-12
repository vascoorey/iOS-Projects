//
//  RecentsCDTVC.m
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "RecentsCDTVC.h"

@implementation RecentsCDTVC

-(void)setup
{
    self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:0];
}

-(void)awakeFromNib
{
    [self setup];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self setup];
    }
    return self;
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    super.managedObjectContext = managedObjectContext;
    if(self.managedObjectContext)
    {
        NSLog(@"Setting up the fetchedResultsController");
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastAccessDate" ascending:YES]];
        NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
        request.predicate = [NSPredicate predicateWithFormat:@"lastAccessDate > %@", yesterday]; // All photos accessed in the last 24 hours
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        NSLog(@"%@", [self.fetchedResultsController fetchedObjects]);
    }
    else
    {
        self.fetchedResultsController = nil;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!self.managedObjectContext)
    {
        [self useSPoTDocument];
    }
    self.shouldMarkAccessDate = NO;
}

-(void)useSPoTDocument
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
