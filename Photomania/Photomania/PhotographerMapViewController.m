//
//  PhotographerMapViewController.m
//  Photomania
//
//  Created by Vasco Orey on 3/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PhotographerMapViewController.h"
#import <CoreData/CoreData.h>
#import "Photographer+MKAnnotation.h"

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

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"setPhotographer:" sender:view];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"setPhotographer:"])
    {
        if([sender isKindOfClass:[MKAnnotationView class]])
        {
            MKAnnotationView *mkAView = (MKAnnotationView *)sender;
            if([mkAView.annotation isKindOfClass:[Photographer class]])
            {
                Photographer *photographer = mkAView.annotation;
                NSLog(@"%@", photographer.managedObjectContext);
                if([segue.destinationViewController respondsToSelector:@selector(setPhotographer:)])
                {
                    [segue.destinationViewController performSelector:@selector(setPhotographer:) withObject:photographer];
                }
            }
        }
    }
}

@end
