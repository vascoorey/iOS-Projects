//
//  PhotographerCDTVC.m
//  Photomania
//
//  Created by Vasco Orey on 3/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PhotographerCDTVC.h"
#import "Photographer.h"

@interface PhotographerCDTVC ()

@end

@implementation PhotographerCDTVC

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if(_managedObjectContext)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil; // Get all photographers !
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    else
    {
        self.fetchedResultsController = nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photographer"];
    
    Photographer *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photographer.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [photographer.photos count]];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if([sender isKindOfClass:[UITableViewCell class]])
    {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    if(indexPath)
    {
        if([segue.identifier isEqualToString:@"setPhotographer:"])
        {
            Photographer *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if([segue.destinationViewController respondsToSelector:@selector(setPhotographer:)])
            {
                [segue.destinationViewController performSelector:@selector(setPhotographer:) withObject:photographer];
            }
        }
    }
}

@end
