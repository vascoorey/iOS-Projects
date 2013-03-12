//
//  SharedContext.h
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedContext : NSObject

+(void)setSharedContext:(NSManagedObjectContext *)context;
+(NSManagedObjectContext *)context;

@end
