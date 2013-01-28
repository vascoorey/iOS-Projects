//
//  ListDetailViewController.m
//  Checklists
//
//  Created by Vasco Orey on 1/25/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "ListDetailViewController.h"
#import "Checklist.h"

@interface ListDetailViewController ()
@property (nonatomic, strong) NSString *iconName;
@end

@implementation ListDetailViewController

#pragma mark UIKit

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        self.iconName = @"Folder";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(self.checklistToEdit)
    {
        self.title = @"Edit Checklist";
        self.iconName = self.checklistToEdit.iconName;
        self.textField.text = self.checklistToEdit.name;
        self.doneBarButton.enabled = YES;
    }
    
    self.iconImageView.image = [UIImage imageNamed:self.iconName];
}

- (void)viewDidUnload {
    [self setIconImageView:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PickIcon"])
    {
        IconPickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

#pragma mark TextField

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.doneBarButton.enabled = newText.length > 0;
    return YES;
}

#pragma mark Actions

-(IBAction)cancel
{
    [self.delegate listDetailViewControllerDidCancel:self];
}

-(IBAction)done
{
    if(self.checklistToEdit)
    {
        self.checklistToEdit.name = self.textField.text;
        self.checklistToEdit.iconName = self.iconName;
        [self.delegate listDetailViewController:self didFinishEditingChecklist:self.checklistToEdit];
    }
    else
    {
        [self.delegate listDetailViewController:self didFinishAddingChecklist:[Checklist checklistWithName:self.textField.text andIcon:self.iconName]];
    }
}

#pragma mark TableView

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1)
    {
        return indexPath;
    }
    else
    {
        return nil;
    }
}

-(void)iconPicker:(IconPickerViewController *)picker didPickIcon:(NSString *)iconName
{
    self.iconName = iconName;
    self.iconImageView.image = [UIImage imageNamed:self.iconName];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
