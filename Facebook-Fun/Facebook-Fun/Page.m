//
//  Page.m
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/27/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Page.h"

@implementation Page

-(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

-(UIImage *)thumbnail
{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.thumbnailURL]]];
}

@end
