//
//  Cache+Create.h
//  Facebook-Fun
//
//  Created by Vasco Orey on 4/4/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Cache.h"

@interface Cache (Create)

+(Cache *)cacheWithIndentifier:(NSString *)identifier inManagegObjectContext:(NSManagedObjectContext *)context;

@end
