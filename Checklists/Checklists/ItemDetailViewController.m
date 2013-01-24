//
//  AddItemViewController.m
//  Checklists
//
//  Created by Vasco Orey on 1/23/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "ItemDetailViewController.h"

@interface ItemDetailViewController ()

@end

@implementation ItemDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Make it obvious this is a text field!
    [self.textField becomeFirstResponder];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if(self.itemToEdit)
    {
        self.title = @"Edit Item";
        self.textField.text = self.itemToEdit.text;
        self.doneBarButton.enabled = true;
    }
}

-(IBAction)cancel
{
    [self.delegate itemDetailViewControllerDidCancel:self];
}

-(IBAction)done
{
    if(self.itemToEdit)
    {
        self.itemToEdit.text = self.textField.text;
        [self.delegate itemDetailViewController:self didFinishEditingItem:self.itemToEdit];
    } else
    {
        [self.delegate itemDetailViewController:self didFinishAddingItem:[ChecklistItem itemWithText:self.textField.text]];
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)viewDidUnload {
    [self setTextField:nil];
    [self setDoneBarButton:nil];
    [super viewDidUnload];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.doneBarButton.enabled = [[textField.text stringByReplacingCharactersInRange:range withString:string] length] > 0;
    return YES;
}

@end

