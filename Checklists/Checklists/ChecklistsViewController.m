//
//  ChecklistsViewController.m
//  Checklists
//
//  Created by Vasco Orey on 1/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "ChecklistsViewController.h"

@interface ChecklistsViewController ()
@property (nonatomic, strong) NSMutableArray *rows;
@end

@implementation ChecklistsViewController

@synthesize rows = _rows;

-(NSMutableArray *)rows
{
    if(!_rows)
    {
        _rows = [NSMutableArray arrayWithObjects:@"Walk the dog", @"Brush my teeth", @"Learn iOS development...", @"Soccer practice", @"Eat ice cream", nil];
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
    return [self.rows count] * 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    // Rethink this bit... Use introspection to guard !
    UILabel *cellLabel = (UILabel *)[cell viewWithTag:1000];
    cellLabel.text = (NSString *)[self.rows objectAtIndex:indexPath.row % 5];
    return cell;
}

@end
