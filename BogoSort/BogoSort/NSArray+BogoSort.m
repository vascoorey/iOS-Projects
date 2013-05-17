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
