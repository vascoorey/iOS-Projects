//
//  PhotosByPhotographerMapViewController.m
//  Photomania
//
//  Created by Vasco Orey on 3/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PhotosByPhotographerMapViewController.h"
#import "Photo+MKAnnotation.h"

@interface PhotosByPhotographerMapViewController ()

@end

@implementation PhotosByPhotographerMapViewController

-(void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    if(self.view.window)
    {
        [self reload];
    }
}

-(void)reload
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
    NSArray *photos = [self.photographer.managedObjectContext executeFetchRequest:request error:NULL];
    NSLog(@"%d", [photos count]);
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:photos];
    Photo *photo = [photos lastObject];
    if(photo)
    {
        self.mapView.centerCoordinate = photo.coordinate;
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self reload];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"setPhoto:" sender:view];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"setPhoto:"])
    {
        if([sender isKindOfClass:[MKAnnotationView class]])
        {
            MKAnnotationView *mkAView = (MKAnnotationView *)sender;
            if([mkAView.annotation isKindOfClass:[Photo class]])
            {
                Photo *photo = mkAView.annotation;
                NSLog(@"%@", photo.managedObjectContext);
                if([segue.destinationViewController respondsToSelector:@selector(setPhoto:)])
                {
                    [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photo];
                }
            }
        }
    }
}

@end
