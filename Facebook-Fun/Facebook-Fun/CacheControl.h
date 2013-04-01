//
//  CacheControl.h
//  Facebook-Fun
//
//  Created by Vasco Orey on 2/28/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheControl : NSObject

+(CacheControl *)sharedControl;
// Returns nil if the identifier doesn't exist in cache
-(NSData *)fetchDataWithIdentifier:(NSString *)identifier;
-(NSData *)fetchExpiringDataWithIdentifier:(NSString *)identifier;
// If the identifier already exists in cache this will do nothing
-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier;
// If still in cache after expiration date it will be deleted
-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier expiration:(NSDate *)expirationDate;

@end
