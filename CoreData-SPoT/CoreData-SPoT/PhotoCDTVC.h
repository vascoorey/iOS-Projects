//
//  PhotoCDTVC.h
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//
// Performs selector setImageURL: at destination of setImageURL: segue

#import "CoreDataTableViewController.h"

@interface PhotoCDTVC : CoreDataTableViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL shouldMarkAccessDate;
@end
