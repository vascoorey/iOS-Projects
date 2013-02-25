//
//  StanfordPhotosTVC.m
//  SPoT
//
//  Created by Vasco Orey on 2/25/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "StanfordPhotosTVC.h"
#import "FlickrFetcher.h"

@implementation StanfordPhotosTVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.photos = [FlickrFetcher stanfordPhotos];
}

@end
