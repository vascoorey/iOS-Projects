//
//  ListDetailViewController.h
//  Checklists
//
//  Created by Vasco Orey on 1/25/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ListDetailViewController;
@class Checklist;

@protocol ListDetailViewControllerDelegate <NSObject>

-(void)listDetailViewControllerDidCancel:(ListDetailViewController *)controller;
-(void)listDetailViewController:(ListDetailViewController *)controller
       didFinishAddingChecklist:(Checklist *)checklist;
-(void)listDetailViewController:(ListDetailViewController *)controller
      didFinishEditingChecklist:(Checklist *)checklist;

@end

@interface ListDetailViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneBarButton;
@property (nonatomic, weak) id <ListDetailViewControllerDelegate> delegate;
@property (nonatomic, strong) Checklist *checklistToEdit;

-(IBAction)done;
-(IBAction)cancel;

@end
