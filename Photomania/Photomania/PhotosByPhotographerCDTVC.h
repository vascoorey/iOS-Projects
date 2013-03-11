//
//  PhotosByPhotographerCDTVC.h
//  Photomania
//
//  Created by Vasco Orey on 3/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Photographer.h"

@interface PhotosByPhotographerCDTVC : CoreDataTableViewController

@property (nonatomic, strong) Photographer *photographer;

@end
