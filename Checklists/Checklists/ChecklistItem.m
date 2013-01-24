//
//  ChecklistItem.m
//  Checklists
//
//  Created by Vasco Orey on 1/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "ChecklistItem.h"

@implementation ChecklistItem

@synthesize text = _text;
@synthesize checked = _checked;

-(id) initWithText:(NSString *)text andChecked:(BOOL)checked
{
    if((self = [super init]))
    {
        self.text = text;
        _checked = checked;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]))
    {
        self.text = (NSString *)[aDecoder decodeObjectForKey:@"Text"];
        _checked = [aDecoder decodeBoolForKey:@"Checked"];
    }
    return self;
}

-(void)toggleChecked
{
    _checked = !_checked;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"Text"];
    [aCoder encodeBool:self.checked forKey:@"Checked"];
}

+(ChecklistItem *)itemWithItem:(NSString *)item andChecked:(BOOL)checked
{
    return [[[self class] alloc] initWithText:item andChecked:checked];
}

+(ChecklistItem *)itemWithItem:(NSString *)item
{
    return [[[self class] alloc] initWithText:item andChecked:NO];
}

@end
