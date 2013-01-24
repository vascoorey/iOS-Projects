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
}

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

@end
