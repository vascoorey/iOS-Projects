//
//  Note.h
//  MagicalRecordTest
//
//  Created by Vasco Orey on 5/9/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * keywords;

@end
