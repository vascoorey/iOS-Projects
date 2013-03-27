//
//  Page.h
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/27/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Page : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

// Blocks
-(UIImage *)thumbnail;

@end
