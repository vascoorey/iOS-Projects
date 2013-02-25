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

-(void)setup
{
    self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:0];
}

-(void)awakeFromNib
{
    [self setup];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.photos = [self recentPhotos];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.photos = [self recentPhotos];
}

-(NSArray *)recentPhotos
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:RECENT_PHOTOS_KEY];
}

@end
