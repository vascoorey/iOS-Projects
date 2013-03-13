//
//  PhotographerMapViewController.m
//  Photomania
//
//  Created by Vasco Orey on 3/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PhotographerMapViewController.h"
#import <CoreData/CoreData.h>

@implementation PhotographerMapViewController

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if(self.view.window)
    {
        [self reload];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self reload];
}

-(void)reload
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.predicate = [NSPredicate predicateWithFormat:@"photos.@count > 2"];
    NSArray *photographers = [self.managedObjectContext executeFetchRequest:request error:NULL];
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSLog(@"Loading annotations: %d", [photographers count]);
    [self.mapView addAnnotations:photographers];
}

@end
