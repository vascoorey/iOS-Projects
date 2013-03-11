//
//  PhotosForTagCDTVC.h
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Tag.h"

@interface PhotosForTagCDTVC : CoreDataTableViewController

@property (nonatomic, strong) Tag *tag;

@end
