//
//  GameResult.m
//  Matchismo
//
//  Created by Vasco Orey on 2/9/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "GameResult.h"

@interface GameResult()
@property (nonatomic, readwrite, strong) NSDate *start;
@property (nonatomic, readwrite, strong) NSDate *end;
-(void)synchronize;
-(id)asPropertyList;
@end

@implementation GameResult

#define ALL_RESULTS_KEY @"GameResult_All"
#define START_DATE_KEY @"StartDate"
#define END_DATE_KEY @"EndDate"
#define SCORE_KEY @"Score"

// Designated Initializer
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

// Convenience Initializer
-(id)initFromPropertyList:(id)plist
{
    if((self = [self init]))
    {
        if([plist isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *resultDictionary = (NSDictionary *)plist;
            _start = resultDictionary[START_DATE_KEY];
            _end = resultDictionary[END_DATE_KEY];
            _score = [resultDictionary[SCORE_KEY] intValue];
            if(!_start || !_end)
            {
                self = nil;
            }
        }
        else
        {
            self = nil;
        }
    }
    return self;
}

-(NSTimeInterval)duration
{
    return [self.end timeIntervalSinceDate:self.start];
}

-(void)setScore:(NSInteger)score
{
    _score = score;
    self.end = [NSDate date];
    [self synchronize];
}

-(void)synchronize
{
    NSMutableDictionary *mutableGameResultsFromUserDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_RESULTS_KEY] mutableCopy];
    if(!mutableGameResultsFromUserDefaults)
    {
        mutableGameResultsFromUserDefaults = [[NSMutableDictionary alloc] init];
    }
    mutableGameResultsFromUserDefaults[[self.start description]] = [self asPropertyList];
    [[NSUserDefaults standardUserDefaults] setObject:mutableGameResultsFromUserDefaults forKey:ALL_RESULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id)asPropertyList
{
    return @{ START_DATE_KEY : self.start, END_DATE_KEY : self.end, SCORE_KEY : @(self.score) };
}

-(NSComparisonResult)compareByDate:(GameResult *)otherResult
{
    return [self.start compare:otherResult.start];
}

-(NSComparisonResult)compareByScore:(GameResult *)otherResult
{
    return self.score < otherResult.score ? NSOrderedDescending : (self.score == otherResult.score ? NSOrderedSame : NSOrderedAscending);
}

-(NSComparisonResult)compareByDuration:(GameResult *)otherResult
{
    return self.duration < otherResult.duration ? NSOrderedAscending : (self.duration == otherResult.duration ? NSOrderedSame : NSOrderedDescending);
}

+(NSArray *)allGameResults
{
    NSMutableArray *allGameResults = [[NSMutableArray alloc] init];
    
    for(id plist in [[[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_RESULTS_KEY] allValues])
    {
        GameResult *result = [[GameResult alloc] initFromPropertyList:plist];
        [allGameResults addObject:result];
    }
    
    return allGameResults;
}

@end
