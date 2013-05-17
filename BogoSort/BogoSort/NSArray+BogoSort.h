//
//  NSArray+BogoSort.h
//  BogoSort
//
//  Created by Vasco Orey on 5/17/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (BogoSort)

//WARNING:
//COMPLEXITY:
//Worst case: unbounded
//Average case: O(n * n!)
//Best case: O(1)
//NOTES:
//Will sort the elements on the list according to their intValue
//You have been warned that this is a terrible method.
//Don't call it. Ever.
-(NSArray *)bogoSort;

@end
