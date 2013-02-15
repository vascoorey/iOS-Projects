//
//  GameSettings.h
//  Matchismo
//
//  Created by Vasco Orey on 2/15/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameSettings.h"

@interface AllGameSettings : NSObject

+(void)setSettings:(GameSettings *)settings forGame:(NSString *)game;
+(GameSettings *)settingsForGame:(NSString *)game;

@end
