//
//  BogoSortTests.m
//  BogoSortTests
//
//  Created by Vasco Orey on 5/17/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "BogoSortTests.h"
#import "NSArray+BogoSort.h"

@implementation BogoSortTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void)testSlowBogoSort
{
    NSArray *a1 = @[@(1),@(0),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10),@(11),@(12),@(13),@(14),@(15),@(16),@(17),@(18),@(19)];
    NSArray *a2 = @[@(0),@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10),@(11),@(12),@(13),@(14),@(15),@(16),@(17),@(18),@(19)];
    STAssertEqualObjects([a1 slowBogoSort], a2, @"Did not sort!");
}

@end
