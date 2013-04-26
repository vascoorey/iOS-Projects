//
//  GridView.h
//  SoundGrid
//
//  Created by Vasco Orey on 4/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GridViewDelegate
@required
-(void)didDetectTouchAtRow:(NSInteger)row col:(NSInteger)col started:(BOOL)started;
@optional
-(BOOL)shouldHandleTouchEvent:(UITouch *)touch;
@end

@interface GridView : UIView
/*
 * This view will convert the contents of this array into a grid of different colors
 *  according to the array's contents.
 *  0 = clear
 *  1 = blue
 *  2 = green
 *  3 = yellow
 *  4 = red
 * gridArray should be an NSArray of NSArrays with exactly the same number of items.
 * Each sub-array should contain NSNumbers 0-4.
 * If those conditions are not met then behavior is unspecified.
 */
@property (nonatomic, strong) NSArray *grid;
@property (nonatomic, weak) id <GridViewDelegate> delegate;

-(void)activateRow:(NSInteger)row col:(NSInteger)col color:(NSInteger)color;

@end
