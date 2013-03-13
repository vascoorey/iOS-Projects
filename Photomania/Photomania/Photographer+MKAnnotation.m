//
//  Photographer+MKAnnotation.m
//  Photomania
//
//  Created by Vasco Orey on 3/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Photographer+MKAnnotation.h"

@implementation Photographer (MKAnnotation)

-(NSString *)title
{
    return self.name;
}

-(NSString *)subtitle
{
    return [NSString stringWithFormat:@"%d photos", [self.photos count]];
}

-(CLLocationCoordinate2D)coordinate
{
    return [[self.photos anyObject] coordinate];
}

-(UIImage *)thumbnail
{
    return [[self.photos anyObject] thumbnail];
}

@end
