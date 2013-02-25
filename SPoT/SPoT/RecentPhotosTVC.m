//
//  RecentPhotosTVC.m
//  SPoT
//
//  Created by Vasco Orey on 2/25/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "RecentPhotosTVC.h"
#import "Utils.h"

@interface RecentPhotosTVC ()

@end

@implementation RecentPhotosTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.photos = [self recentPhotos];
}

-(NSArray *)recentPhotos
{
    id sharedRecents = [[NSUserDefaults standardUserDefaults] objectForKey:RECENT_PHOTOS_KEY];
    return sharedRecents;
}

@end
