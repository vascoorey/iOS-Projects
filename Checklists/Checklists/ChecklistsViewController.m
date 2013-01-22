//
//  ChecklistsViewController.m
//  Checklists
//
//  Created by Vasco Orey on 1/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "ChecklistsViewController.h"

@interface ChecklistsViewController ()
@property (nonatomic, strong) NSMutableDictionary *rows;
@end

@implementation ChecklistsViewController

@synthesize rows = _rows;

-(NSMutableDictionary *)rows
{
    if(!_rows)
    {
        _rows = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"Walk the dog", [NSNumber numberWithBool:NO], @"Brush my teeth", [NSNumber numberWithBool:YES], @"Learn iOS development...", [NSNumber numberWithBool:NO], @"Soccer practice", [NSNumber numberWithBool:YES], @"Eat ice cream", nil];
    }
    // Returns an immutable copy
    return _rows;
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    // Rethink this bit... Use introspection to guard !
    UILabel *cellLabel = (UILabel *)[cell viewWithTag:1000];
    NSArray *allKeys = [self.rows allKeys];
    cellLabel.text = (NSString *)[allKeys objectAtIndex:indexPath.row];
    [self configureCheckmarkForCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSArray *allKeys = [self.rows allKeys];
    BOOL isChecked = [[self.rows objectForKey:[allKeys objectAtIndex:indexPath.row]] boolValue];
    [self.rows setObject:[NSNumber numberWithBool:!isChecked] forKey:[allKeys objectAtIndex:indexPath.row]];
    [self configureCheckmarkForCell:cell atIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)configureCheckmarkForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BOOL isChecked = NO;
    NSArray *allKeys = [self.rows allKeys];
    if((isChecked = [[self.rows objectForKey:[allKeys objectAtIndex:indexPath.row]] boolValue]))
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
