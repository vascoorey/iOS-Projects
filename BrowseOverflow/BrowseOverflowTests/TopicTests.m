//
//  TopicTests.m
//  BrowseOverflow
//
//  Created by Vasco Orey on 5/8/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "TopicTests.h"
#import "Topic.h"

@interface TopicTests ()
@property (nonatomic, strong) Topic *topic;
@end

@implementation TopicTests

-(void)setUp
{
    self.topic = [[Topic alloc] initWithName:@"Name" tag:@"Tag"];
    [super setUp];
}

-(void)tearDown
{
    self.topic = nil;
    [super tearDown];
}

-(void)testThatTopicExists
{
    STAssertNotNil(self.topic, @"Should be able to create a new Topic instance");
}

-(void)testNamedTopic
{
    STAssertEqualObjects(self.topic.name, @"Name", @"Topic's name should be 'Name'");
}

-(void)testThatTopicHasATag
{
    STAssertEqualObjects(self.topic.tag, @"Tag", @"Topic's tag should be Tag");
}

@end
