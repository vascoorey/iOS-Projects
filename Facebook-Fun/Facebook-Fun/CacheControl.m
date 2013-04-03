//
//  CacheControl.m
//  SPoT
//
//  Created by Vasco Orey on 2/28/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CacheControl.h"
#import "NSString+MD5.h"
#import "NSData+MD5.h"

@interface CacheControl ()
@property (nonatomic, strong) NSTimer *cleanupTimer;
@end

@implementation CacheControl

#define MAX_CACHE_IPHONE 8388608
#define MAX_CACHE_IPAD 33554432

+(CacheControl *)sharedControl
{
    return nil;
}

// Returns nil if the identifier doesn't exist in cache
-(NSData *)fetchDataWithIdentifier:(NSString *)identifier
{
    return nil;
}

// If the identifier already exists in cache this will do nothing
-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier
{
    return;
}

// If still in cache after expiration date it will be deleted
-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier expiration:(NSDate *)expirationDate
{
    return;
}

@end
