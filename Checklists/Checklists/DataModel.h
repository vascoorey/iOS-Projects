//
//  DataModel.h
//  Checklists
//
//  Created by Vasco Orey on 1/26/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (nonatomic, strong) NSMutableArray *lists;

-(void)saveChecklists;

@end
