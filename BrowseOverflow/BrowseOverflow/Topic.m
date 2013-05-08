//
//  Topic.m
//  BrowseOverflow
//
//  Created by Vasco Orey on 5/8/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Topic.h"

@interface Topic()
@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, copy) NSString *tag;
@end

@implementation Topic

-(id)initWithName:(NSString *)name
{
    if((self = [super init]))
    {
        self.name = name;
    }
    return self;
}

-(id)initWithName:(NSString *)name tag:(NSString *)tag
{
    if((self = [super init]))
    {
        self.name = name;
        self.tag = tag;
    }
    return self;
}

@end
