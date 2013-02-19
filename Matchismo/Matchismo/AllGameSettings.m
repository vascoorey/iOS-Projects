//
//  GameSettings.m
//  Matchismo
//
//  Created by Vasco Orey on 2/15/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "AllGameSettings.h"

@interface AllGameSettings()
@property (nonatomic, strong) NSMutableDictionary *allGameSettings;
@end

@implementation AllGameSettings

-(NSMutableDictionary *)allGameSettings
{
    if(!_allGameSettings)
    {
        _allGameSettings = [[NSMutableDictionary alloc] init];
    }
    return _allGameSettings;
}

static AllGameSettings *gameSettings;

+(AllGameSettings *)sharedSettings
{
    if(!gameSettings)
    {
        gameSettings = [[AllGameSettings alloc] init];
    }
    return gameSettings;
}

+(void)setSettings:(GameSettings *)settings forGame:(NSString *)game
{
    NSLog(@"Saving settings for %@: %d, %d", game, settings.startingCardCount, settings.shouldRedealCards);
    [self sharedSettings].allGameSettings[game] = settings;
}

+(GameSettings *)settingsForGame:(NSString *)game
{
    GameSettings *settings = nil;
    if([[[self sharedSettings].allGameSettings allKeys] containsObject:game])
    {
        settings = [self sharedSettings].allGameSettings[game];
    }
    return settings;
}

@end
