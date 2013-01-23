//
//  AddItemViewController.m
//  Checklists
//
//  Created by Vasco Orey on 1/23/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "AddItemViewController.h"

@interface AddItemViewController ()

@end

@implementation AddItemViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Make it obvious this is a text field!
    [self.textField becomeFirstResponder];
}

-(IBAction)cancel
{
    [self.delegate addItemViewControllerDidCancel:self];
}

-(IBAction)done
{
    [self.delegate addItemViewController:self didFinishAddingItem:[ChecklistItem itemWithItem:self.textField.text]];
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

