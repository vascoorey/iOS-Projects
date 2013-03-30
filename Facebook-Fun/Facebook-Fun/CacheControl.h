//
//  CacheControl.h
//  Facebook-Fun
//
//  Created by Vasco Orey on 2/28/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheControl : NSObject

// Returns nil if the identifier doesn't exist in cache
+(NSData *)fetchDataWithIdentifier:(NSString *)identifier;
// Behavior is undefined if the identifier already exists in cache
+(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier;

@end
