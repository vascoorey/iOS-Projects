//
//  CMMotionManager+Shared.m
//  Kitchen-Sink
//
//  Created by Vasco Orey on 3/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CMMotionManager+Shared.h"

@implementation CMMotionManager (Shared)

+(CMMotionManager *)sharedMotionManager
{
    static CMMotionManager *sharedManager;
    if(!sharedManager)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[CMMotionManager alloc] init];
        });
    }
    return sharedManager;
}

@end
