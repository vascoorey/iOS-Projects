//
//  AllListsViewController.m
//  Checklists
//
//  Created by Vasco Orey on 1/24/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "AllListsViewController.h"
#import "ChecklistViewController.h"
#import "Checklist.h"

@interface AllListsViewController ()

@end

@implementation AllListsViewController

@synthesize lists = _lists;

-(NSMutableArray *)lists
{
    if(!_lists)
    {
        _lists = [[NSMutableArray alloc] init];
    }
    return _lists;
}

#pragma mark UIKit

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        [self.lists addObject:[Checklist checklistWithName:@"Birthdays"]];
        [self.lists addObject:[Checklist checklistWithName:@"Shopping"]];
        [self.lists addObject:[Checklist checklistWithName:@"Work"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowChecklist"])
    {
        ChecklistViewController *controller = segue.destinationViewController;
        controller.checklist = sender;
    }
    else if([segue.identifier isEqualToString:@"AddChecklist"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        ListDetailViewController *listController = (ListDetailViewController *)navigationController.topViewController;
        listController.delegate = self;
        listController.checklistToEdit = nil;
    }
}

#pragma mark TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lists count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [(Checklist *)[self.lists objectAtIndex:indexPath.row] name];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowChecklist" sender:[self.lists objectAtIndex:indexPath.row]];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.lists removeObjectAtIndex:indexPath.row];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"ListNavigationController"];
    ListDetailViewController *controller = (ListDetailViewController *)navigationController.topViewController;
    controller.delegate = self;
    controller.checklistToEdit = [self.lists objectAtIndex:indexPath.row];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark ListDetailViewController delegate methods

-(void)listDetailViewControllerDidCancel:(ListDetailViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)listDetailViewController:(ListDetailViewController *)controller didFinishAddingChecklist:(Checklist *)checklist
{
    [self.lists addObject:checklist];
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.lists.count - 1 inSection:0];
    NSArray *indexPath = [NSArray arrayWithObject:path];
    [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)listDetailViewController:(ListDetailViewController *)controller didFinishEditingChecklist:(Checklist *)checklist
{
    int index = [self.lists indexOfObject:checklist];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    cell.textLabel.text = checklist.name;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
