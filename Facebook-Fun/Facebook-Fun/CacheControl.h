//
//  CacheControl.h
//  Facebook-Fun
//
//  Created by Vasco Orey on 2/28/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//
//  NOTE: This class uses CoreData. Assumes all methods are called from the Main Thread.

#import <Foundation/Foundation.h>

@interface CacheControl : NSObject

// Singleton access - Do not alloc init this class !
+(CacheControl *)sharedControl;
// Returns nil if the identifier doesn't exist in cache
-(NSData *)dataWithIdentifier:(NSString *)identifier;
// If the identifier already exists in cache this will replace it's data
-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier;
// If still in cache after expiration date it will be deleted
// If the identifier already exists in cache this will replace it's data
-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier expiration:(NSDate *)expirationDate;

@end
