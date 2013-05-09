//
//  MRTViewController.m
//  MagicalRecordTest
//
//  Created by Vasco Orey on 5/9/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "MRTViewController.h"
#import "Note.h"

@interface MRTViewController ()
@property (nonatomic, strong) NSMutableArray *notes;
@end

@implementation MRTViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupView];
}

-(void)setupView
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editNotes:)];
    self.navigationItem.leftBarButtonItem = editButton;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addNote:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.title = @"Magical Notes";
    //Fetch notes
    [self fetchNotes];
}

-(void)fetchNotes
{
    self.notes = [[Note findAllSortedBy:@"date" ascending:YES] mutableCopy];
}

-(void)editNotes:(id)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

-(void)addNote:(id)sender
{
    //Nothing here...
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Note";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    //Fetch note
    Note *note = self.notes[indexPath.row];
    cell.textLabel.text = note.title;
    cell.detailTextLabel.text = note.keywords;
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
