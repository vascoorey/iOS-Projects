//
//  NetworkActivity.m
//  SPoT
//
//  Created by Vasco Orey on 2/27/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "NetworkActivity.h"

@interface NetworkActivity ()
@property (atomic) NSUInteger count;
@end

@implementation NetworkActivity

-(void)addRequest
{
    self.count ++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = self.count > 0;
}

-(void)popRequest
{
    NSAssert(self.count > 0, @"Seems like you called removeRequest one too many times!");
    self.count --;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = self.count > 0;
}

+(NetworkActivity *)sharedActivity
{
    static NetworkActivity *sharedActivity = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedActivity = [[NetworkActivity alloc] init];
    });
    return sharedActivity;
}

+(void)addRequest
{
    [[self sharedActivity] addRequest];
}

+(void)popRequest
{
    [[self sharedActivity] popRequest];
}

@end
