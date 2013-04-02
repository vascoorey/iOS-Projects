//
//  MTViewController.m
//  Geofencing
//
//  Created by Vasco Orey on 4/2/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MTViewController.h"

@interface MTViewController () <CLLocationManagerDelegate>
@property (nonatomic) BOOL didStartMonitoringRegion;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *geofences;
@end

@implementation MTViewController

#pragma mark - Defines

#define UPDATE_RADIUS 250.0f

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if([locations count] && !self.didStartMonitoringRegion)
    {
        self.didStartMonitoringRegion = YES;
        // Get current location
        CLLocation *location = locations[0];
        // Initialize the region to monitor
        CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:location.coordinate radius:UPDATE_RADIUS identifier:[[NSUUID UUID] UUIDString]];
        // Start monitoring region
        [self.locationManager startMonitoringForRegion:region];
        [self.locationManager stopUpdatingLocation];
        // Update the tableView
        [self.geofences addObject:region];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([self.geofences count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - Geofence Methods

-(void)addCurrentLocation:(id)sender
{
    self.didStartMonitoringRegion = NO;
    [self.locationManager startUpdatingLocation];
}

-(void)editTableView:(id)sender
{
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    // Update the edit button
    self.navigationItem.rightBarButtonItem.title = self.tableView.isEditing ? @"Done" : @"Edit";
}

-(void)updateView
{
    if([self.geofences count])
    {
        // Update Edit Button
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        // No geofences
        [self.tableView setEditing:NO animated:YES];
        // Update buttons
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.title = @"Edit";
    }
    // Only enable the add button if we're under 20 geofences
    self.navigationItem.leftBarButtonItem.enabled = [self.geofences count] < 20;
}

#pragma mark - View Lifecycle

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

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCurrentLocation:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editTableView:)];
    
    self.geofences = [[NSMutableArray alloc] initWithArray:[[self.locationManager monitoredRegions] allObjects]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.geofences ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.geofences count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Geofence Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CLRegion *geofence = self.geofences[indexPath.row];
    CLLocationCoordinate2D center = [geofence center];
    cell.textLabel.text = [NSString stringWithFormat:@"%.1f | %.1f", center.latitude, center.longitude];
    cell.detailTextLabel.text = geofence.identifier;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Fetch the monitored region
        CLRegion *region = self.geofences[indexPath.row];
        // Stop monitoring
        [self.locationManager stopMonitoringForRegion:region];
        [self.geofences removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateView];
    } 
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
