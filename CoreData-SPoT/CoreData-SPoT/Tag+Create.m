//
//  Tag+Create.m
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+(Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Tag *tag = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count] > 1)
    {
        // Handle error
    }
    else if(![matches count])
    {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        tag.name = name;
    }
    else
    {
        tag = [matches lastObject];
    }
    
    return tag;
}

@end
