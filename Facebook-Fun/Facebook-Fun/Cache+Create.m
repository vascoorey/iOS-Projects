//
//  Cache+Create.m
//  Facebook-Fun
//
//  Created by Vasco Orey on 4/4/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Cache+Create.h"

@implementation Cache (Create)

+(Cache *)cacheWithIndentifier:(NSString *)identifier inManagegObjectContext:(NSManagedObjectContext *)context create:(BOOL)create
{
    Cache *cache = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Cache"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count] > 1)
    {
        // Handle error
    }
    else if(![matches count] && create)
    {
        cache = [NSEntityDescription insertNewObjectForEntityForName:@"Cache" inManagedObjectContext:context];
        cache.identifier = identifier;
    }
    else if([matches count] && !create)
    {
        cache = [matches lastObject];
    }
    
    return cache;
}

@end
