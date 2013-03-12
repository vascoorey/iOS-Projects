//
//  SharedContext.m
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "SharedContext.h"

@interface SharedContext()
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation SharedContext

+(SharedContext *)sharedContext
{
    static SharedContext *sharedContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedContext = [[SharedContext alloc] init];
    });
    return sharedContext;
}

+(void)setSharedContext:(NSManagedObjectContext *)context
{
    [self sharedContext].context = context;
}

+(NSManagedObjectContext *)context
{
    return [self sharedContext].context;
}

@end
