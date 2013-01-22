//
//  ChecklistsViewController.m
//  Checklists
//
//  Created by Vasco Orey on 1/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "ChecklistsViewController.h"
#import "ChecklistItem.h"

@interface ChecklistsViewController ()
@property (nonatomic, strong) NSArray *rows;
@end

@implementation ChecklistsViewController

@synthesize rows = _rows;

-(NSArray *)rows
{
    if(!_rows)
    {
        _rows = [NSMutableArray arrayWithObjects:[ChecklistItem itemWithItem:@"Walk the dog" andChecked:NO], [ChecklistItem itemWithItem:@"Brush my teeth" andChecked:NO], [ChecklistItem itemWithItem:@"Learn iOS development..." andChecked:NO], [ChecklistItem itemWithItem:@"Soccer practice" andChecked:NO], [ChecklistItem itemWithItem:@"Eat ice cream" andChecked:NO], nil];
    }
    // Returns an immutable copy
    return [_rows copy];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rows count];
}

// Rethink this bit... Use introspection to guard !

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    UILabel *cellLabel = (UILabel *)[cell viewWithTag:1000];
    ChecklistItem *item = (ChecklistItem *)[self.rows objectAtIndex:indexPath.row];
    cellLabel.text = item.text;
    [self configureCheckmarkForCell:cell forChecklistItem:item];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ChecklistItem *item = (ChecklistItem *)[self.rows objectAtIndex:indexPath.row];
    item.checked = !item.checked;
    
    [self configureCheckmarkForCell:cell forChecklistItem:item];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)configureCheckmarkForCell:(UITableViewCell *)cell forChecklistItem:(ChecklistItem *)item
{
    if(item.checked)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
