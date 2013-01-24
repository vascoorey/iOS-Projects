//
//  AddItemViewController.h
//  Checklists
//
//  Created by Vasco Orey on 1/23/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChecklistItem.h"

@class ItemDetailViewController;

@protocol ItemDetailControllerDelegate <NSObject>

-(void)itemDetailViewControllerDidCancel:(ItemDetailViewController *)controller;
-(void)itemDetailViewController:(ItemDetailViewController *)controller didFinishAddingItem:(ChecklistItem *)item;
-(void)itemDetailViewController:(ItemDetailViewController *)controller didFinishEditingItem:(ChecklistItem *)item;

@end

@interface ItemDetailViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (weak, nonatomic) id <ItemDetailControllerDelegate> delegate;
@property (weak, nonatomic) ChecklistItem *itemToEdit;

-(IBAction)cancel;
-(IBAction)done;

@end
