//
//  GameResult.m
//  Matchismo
//
//  Created by Vasco Orey on 2/9/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "GameResult.h"

@interface GameResult()
@property (nonatomic, readwrite) NSDate *start;
@property (nonatomic, readwrite) NSDate *end;
@end

@implementation GameResult

-(id)init
{
    if((self =  [super init]))
    {
        _start = [NSDate date];
        _end = [NSDate date];
        _score = 0;
    }
    return self;
}

-(void)setScore:(NSInteger)score
{
    _score = score;
    self.end = [NSDate date];
}

+(NSArray *)allResults
{
    
}

@end
