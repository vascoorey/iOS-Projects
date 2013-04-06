//
//  Cache.h
//  Facebook-Fun
//
//  Created by Vasco Orey on 4/5/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Cache : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSDate * expirationDate;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSDate * timestamp;

@end
