//
//  PhotoViewController.m
//  Photomania
//
//  Created by Vasco Orey on 3/15/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PhotoViewController.h"
#import "MapViewController.h"
#import "Photo+MKAnnotation.h"

@interface PhotoViewController ()
@property (nonatomic, strong) MapViewController *mapVC;
@end

@implementation PhotoViewController

-(void)setPhoto:(Photo *)photo
{
    _photo = photo;
    self.title = photo.title;
    self.imageURL = [NSURL URLWithString:photo.imageURL];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.mapVC.mapView addAnnotation:self.photo];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"setMapVC:"])
    {
        if([segue.destinationViewController isKindOfClass:[MapViewController class]])
        {
            self.mapVC = (MapViewController *)segue.destinationViewController;
        }
    }
}

@end
