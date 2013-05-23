//
//  NSArray+BogoSort.m
//  BogoSort
//
//  Created by Vasco Orey on 5/17/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "NSArray+BogoSort.h"

@implementation NSArray (BogoSort)

-(NSArray *)bogoSort
{
    NSMutableArray *mutableSelf = [self mutableCopy];
    while(![mutableSelf isSorted])
    {
        // the Knuth shuffle
        for (NSInteger i = [mutableSelf count] - 1; i > 0; i--)
        {
            [mutableSelf exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform(i+1)];
        }
    }
    return mutableSelf;
}

-(NSArray *)slowBogoSort
{
    if(![self isSorted])
    {
        NSMutableArray *mutableSelf = [self mutableCopy];
        NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:[self count]];
        BOOL done = NO;
        while(!done)
        {
            if(![sortedArray count])
            {
                NSLog(@"Starting...");
                NSInteger index = arc4random_uniform([mutableSelf count] + 1);
                [sortedArray addObject:mutableSelf[index]];
                [mutableSelf removeObjectAtIndex:index];
                index = arc4random_uniform([mutableSelf count] + 1);
                [sortedArray addObject:mutableSelf[index]];
                [mutableSelf removeObjectAtIndex:index];
            }
            else
            {
                NSLog(@"Continuing...");
                NSInteger index = arc4random_uniform([mutableSelf count] + 1);
                [sortedArray addObject:mutableSelf[index]];
                [mutableSelf removeObjectAtIndex:index];
            }
            printf("[");
            for(int i = 0; i < [sortedArray count]; i ++)
                printf(" %d ", [sortedArray[i] intValue]);
            printf("]\n");
            if([sortedArray isSorted])
            {
                done = [mutableSelf count] == 0;
            }
            else
            {
                sortedArray = [NSMutableArray arrayWithCapacity:[self count]];
                mutableSelf = [self mutableCopy];
            }
        }
        return sortedArray;
    }
    else
    {
        return self;
    }
}

-(BOOL)isSorted
{
    int count = [self count];
    if(count)
    {
        int lastValue = [self[0] intValue];
        for(int i = 1; i < count; i ++)
        {
            if([self[i] intValue] >= lastValue)
            {
                lastValue = [self[i] intValue];
            }
            else
            {
                return NO;
            }
        }
    }
    return YES;
}

@end
