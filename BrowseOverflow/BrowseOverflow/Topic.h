//
//  Topic.h
//  BrowseOverflow
//
//  Created by Vasco Orey on 5/8/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Topic : NSObject

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *tag;

-(id)initWithName:(NSString *)name tag:(NSString *)tag;

@end
