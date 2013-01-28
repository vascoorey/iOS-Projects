//
//  Checklist.m
//  Checklists
//
//  Created by Vasco Orey on 1/24/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Checklist.h"
#import "ChecklistItem.h"

@implementation Checklist

-(NSMutableArray *)items
{
    if(!_items)
    {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

-(NSComparisonResult)compare:(Checklist *)other
{
    return [self.name localizedStandardCompare:other.name];
}

-(id) initWithName:(NSString *)name
{
    if((self = [super init]))
    {
        self.name = name;
        self.iconName = @"No Icon";
    }
    return self;
}

-(id) initWithName:(NSString *)name andIcon:(NSString *)iconName
{
    if((self = [super init]))
    {
        self.name = name;
        self.iconName = iconName;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]))
    {
        self.name = (NSString *)[aDecoder decodeObjectForKey:@"Name"];
        self.items = [aDecoder decodeObjectForKey:@"Items"];
        self.iconName = (NSString *)[aDecoder decodeObjectForKey:@"IconName"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.items forKey:@"Items"];
    [aCoder encodeObject:self.iconName forKey:@"IconName"];
}

-(int)uncheckedItems
{
    int count = 0;
    for(ChecklistItem *item in self.items)
    {
        if(!item.checked)
        {
            count ++;
        }
    }
    return count;
}

+(Checklist *)checklistWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
}

+(Checklist *)checklistWithName:(NSString *)name andIcon:(NSString *)iconName
{
    return [[[self class] alloc] initWithName:name andIcon:iconName];
}

@end
