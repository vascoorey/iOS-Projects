//
//  PhotographerCDTVC.h
//  Photomania
//
//  Created by Vasco Orey on 3/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//
// Can do "setPhotographer:" segue and will call said method at destination

#import "CoreDataTableViewController.h"

@interface PhotographerCDTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
