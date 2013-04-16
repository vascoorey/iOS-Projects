//
//  GameOfLifeView.h
//  Pool-Of-Sounds
//
//  Created by Vasco Orey on 4/16/13.
//
//

#import "CCLayer.h"

@interface GameOfLifeView : CCLayer

@property (nonatomic, strong) NSArray *rows;
@property (nonatomic) NSInteger rowToHighlight;
@property (nonatomic) ccColor4F cellBeingPlayedColor;
@property (nonatomic) ccColor4F cellColor;

-(id)initWithRect:(CGRect)rect rows:(NSInteger)rows cols:(NSInteger)cols cellWidth:(CGFloat)cellWidth;
-(void)flipCellAtRow:(NSInteger)row col:(NSInteger)col;

@end
