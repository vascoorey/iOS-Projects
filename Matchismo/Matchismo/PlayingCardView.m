//
//  PlayingCardView.m
//  SuperCard
//
//  Created by Vasco Orey on 2/18/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "PlayingCardView.h"

@interface PlayingCardView()
@property (nonatomic) CGFloat faceCardScaleFactor;
@end

@implementation PlayingCardView

@synthesize faceCardScaleFactor = _faceCardScaleFactor;

#define CORNER_RADIUS 12.0f
#define FONT_SCALE_FACTOR 0.20f
#define DEFAULT_FACE_CARD_SCALE_FACTOR 0.90f

-(CGFloat)faceCardScaleFactor
{
    if(!_faceCardScaleFactor)
    {
        _faceCardScaleFactor = DEFAULT_FACE_CARD_SCALE_FACTOR;
    }
    return _faceCardScaleFactor;
}

-(void)setFaceCardScaleFactor:(CGFloat)faceCardScaleFactor
{
    _faceCardScaleFactor = faceCardScaleFactor;
    [self setNeedsDisplay];
}

-(void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if((gesture.state == UIGestureRecognizerStateChanged) ||
       (gesture.state == UIGestureRecognizerStateEnded))
    {
        self.faceCardScaleFactor *= gesture.scale;
        gesture.scale = 1.0f;
    }
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:CORNER_RADIUS];
    [roundedRect addClip];
    
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    
    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
    
    if(self.faceUp)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"%@-%@.png", [self translateSuit], [NSString stringWithFormat:@"%d", self.rank]]);
        UIImage *faceImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@.png", [self translateSuit], [NSString stringWithFormat:@"%d", self.rank]]];
        
        if(faceImage)
        {
            CGRect imageRect = CGRectInset(self.bounds,
                                           self.bounds.size.width * (1.0 - self.faceCardScaleFactor),
                                           self.bounds.size.height * (1.0 - self.faceCardScaleFactor)
                                           );
            [faceImage drawInRect:imageRect];
        }
        else
        {
            [self drawPips];
        }
        [self drawCorners];
    }
    else
    {
        [[UIImage imageNamed:@"card-back.png"] drawInRect:self.bounds];
    }
}

#define PIP_HOFFSET_PERCENTAGE 0.165f
#define PIP_VOFFSET1_PERCENTAGE 0.090f
#define PIP_VOFFSET2_PERCENTAGE 0.175f
#define PIP_VOFFSET3_PERCENTAGE 0.270f
-(void)drawPips
{
    if((self.rank == 1) || (self.rank == 5) || (self.rank == 9) || (self.rank == 3))
    {
        [self drawPipsWithHorizontalOffset:0
                            verticalOffset:0
                        mirroredVertically:NO];
    }
    if((self.rank == 6) || (self.rank == 7) || (self.rank == 8))
    {
        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                            verticalOffset:0
                        mirroredVertically:NO];
    }
    if((self.rank == 2) || (self.rank == 3) || (self.rank == 7) || (self.rank == 8) || (self.rank == 10))
    {
        [self drawPipsWithHorizontalOffset:0
                            verticalOffset:PIP_VOFFSET2_PERCENTAGE
                        mirroredVertically:(self.rank != 7)];
    }
    if((self.rank == 4) || (self.rank == 5) || (self.rank == 6) || (self.rank == 7) || (self.rank == 8) || (self.rank == 9) || (self.rank == 10))
    {
        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                            verticalOffset:PIP_VOFFSET3_PERCENTAGE
                        mirroredVertically:YES];
    }
    if((self.rank == 9) || (self.rank == 10))
    {
        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                            verticalOffset:PIP_VOFFSET1_PERCENTAGE
                        mirroredVertically:YES];
    }
}

-(void)drawPipsWithHorizontalOffset:(CGFloat)hoffset
                     verticalOffset:(CGFloat)voffset
                 upsideDown:(BOOL)upsideDown
{
    if(upsideDown)
    {
        [self pushContextAndRotateUpsideDown];
    }
    CGPoint middle = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    UIFont *pipFont = [UIFont systemFontOfSize:self.bounds.size.width * FONT_SCALE_FACTOR];
    NSAttributedString *attributedSuit = [[NSAttributedString alloc] initWithString:self.suit attributes:@{ NSFontAttributeName : pipFont }];
    CGSize pipSize = [attributedSuit size];
    CGPoint pipOrigin = CGPointMake(
                                    middle.x - pipSize.width / 2.0 - hoffset * self.bounds.size.width,
                                    middle.y - pipSize.height / 2.0 - voffset * self.bounds.size.height
                                    );
    [attributedSuit drawAtPoint:pipOrigin];
    if(hoffset)
    {
        pipOrigin.x +=hoffset * 2.0 * self.bounds.size.width;
        [attributedSuit drawAtPoint:pipOrigin];
    }
    if(upsideDown)
    {
        [self popContext];
    }
}

-(void)drawPipsWithHorizontalOffset:(CGFloat)hoffset
                     verticalOffset:(CGFloat)voffset
                 mirroredVertically:(BOOL)mirroredVertically
{
    [self drawPipsWithHorizontalOffset:hoffset verticalOffset:voffset upsideDown:NO];
    if(mirroredVertically)
    {
        [self drawPipsWithHorizontalOffset:hoffset verticalOffset:voffset upsideDown:YES];
    }
}

-(void)drawCorners
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIFont *cornerFont = [UIFont systemFontOfSize:self.bounds.size.width * FONT_SCALE_FACTOR];
    
    NSMutableAttributedString *cornerText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", [self rankAsString], self.suit] attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : cornerFont}];
    
    CGRect textBounds;
    textBounds.origin = CGPointMake(2.0, 2.0);
    textBounds.size = [cornerText size];
    
    // Top left
    [cornerText drawInRect:textBounds];
    [self pushContextAndRotateUpsideDown];
    // Bottom right
    [cornerText drawInRect:textBounds];
    [self popContext];
}

-(void)pushContextAndRotateUpsideDown
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.bounds.size.width, self.bounds.size.height);
    CGContextRotateCTM(context, M_PI);
}

-(void)popContext
{
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

-(NSString *)translateSuit
{
    return @{ @"♥" : @"heart", @"♦" : @"diamond", @"♣" : @"club", @"♠" : @"spade" }[self.suit];
}

-(NSString *)rankAsString
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"][self.rank];
}

-(void)setFaceUp:(BOOL)faceUp
{
    _faceUp = faceUp;
    [self setNeedsDisplay];
}

-(void)setRank:(NSUInteger)rank
{
    _rank = rank;
    [self setNeedsDisplay];
}

-(void)setSuit:(NSString *)suit
{
    _suit = suit;
    [self setNeedsDisplay];
}

#pragma mark Initialization

-(void)setup
{
    
}

-(void)awakeFromNib
{
    [self setup];
}

-(id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    return self;
}

@end
