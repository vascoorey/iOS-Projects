//
//  ChecklistItem.h
//  Checklists
//
//  Created by Vasco Orey on 1/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChecklistItem : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL checked;

-(id)initWithText:(NSString *)text andChecked:(BOOL)checked;

+(ChecklistItem *)itemWithItem:(NSString *)item andChecked:(BOOL)checked;

@end
