//
//  Tag+Create.h
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+(Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
