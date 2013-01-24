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

-(id) initWithName:(NSString *)name
{
    if((self = [super init]))
    {
        self.name = name;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]))
    {
        self.name = (NSString *)[aDecoder decodeObjectForKey:@"Name"];
        self.items = [aDecoder decodeObjectForKey:@"Items"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.items forKey:@"Items"];
}

-(void)addNewItem:(ChecklistItem *)item
{
    if(![self.items containsObject:item])
    {
        [self.items addObject:item];
    }
}

+(Checklist *)checklistWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
}

@end
