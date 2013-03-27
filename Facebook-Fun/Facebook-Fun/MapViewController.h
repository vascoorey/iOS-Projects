//
//  MapViewController.h
//  Photomania
//
//  Created by Vasco Orey on 3/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//
// Will display a thumbnail in leftCalloutAccessoryView if the annotation implements the method "thumbnail" (return UIImage)

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@end
