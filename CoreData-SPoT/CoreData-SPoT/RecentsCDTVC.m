//
//  RecentsCDTVC.m
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "RecentsCDTVC.h"
#import "SharedContext.h"

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
        self.fetchedResultsController = nil;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"viewed" ascending:YES]];
        NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
        NSLog(@"Comparing with: %@", yesterday);
        request.predicate = [NSPredicate predicateWithFormat:@"(viewed > %@)", yesterday]; // All photos viewed in the last 24 hours
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        NSLog(@"%@", self.fetchedResultsController.fetchedObjects);
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
        self.managedObjectContext = [SharedContext context];
    }
}

@end
