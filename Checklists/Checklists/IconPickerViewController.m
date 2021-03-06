//
//  IconPickerViewController.m
//  Checklists
//
//  Created by Vasco Orey on 1/28/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "IconPickerViewController.h"

@interface IconPickerViewController ()
@property (nonatomic, strong) NSArray *icons;
@end

@implementation IconPickerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.icons = [NSArray arrayWithObjects:@"No Icon", @"Appointments", @"Birthdays", @"Chores", @"Drinks", @"Folder", @"Groceries", @"Inbox", @"Photos", @"Trips", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.icons.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IconCell"];
    NSString *icon = (NSString *)[self.icons objectAtIndex:indexPath.row];
    cell.textLabel.text = icon;
    cell.imageView.image = [UIImage imageNamed:icon];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate iconPicker:self didPickIcon:[self.icons objectAtIndex:indexPath.row]];
}

@end
