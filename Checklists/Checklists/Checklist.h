//
//  Checklist.h
//  Checklists
//
//  Created by Vasco Orey on 1/24/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Checklist : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSString *iconName;

-(int)uncheckedItems;

+(Checklist *)checklistWithName:(NSString *)name;
+(Checklist *)checklistWithName:(NSString *)name andIcon:(NSString *)iconName;

@end
