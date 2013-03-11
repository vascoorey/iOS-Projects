//
//  CacheControl.h
//  SPoT
//
//  Created by Vasco Orey on 2/28/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheControl : NSObject


+(BOOL)containsIdentifier:(NSString *)identifier;
+(void)removeIdentifierAndDeleteFile:(NSString *)identifier;
+(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier;
+(NSData *)getDataFromCache:(NSString *)identifier;

@end
