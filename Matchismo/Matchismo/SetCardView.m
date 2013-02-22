//
//  SetCardView.m
//  Matchismo
//  Drawing code from: https://github.com/codingtogether74/Assignment-3-2013/blob/master/SetGame/SetCardView.m
//
//  Created by Vasco Orey on 2/19/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "SetCardView.h"

@implementation SetCardView

#define CARD_CORNER_RADIUS 12.0f
#define Y_OFFSET 0.05f
#define X_OFFSET 0.1f
#define RECT_SIZE 0.3f

-(void)setColor:(NSUInteger)color
{
    _color = color;
    [self setNeedsDisplay];
}

-(void)setShade:(NSUInteger)shade
{
    _shade = shade;
    [self setNeedsDisplay];
}

-(void)setShape:(NSUInteger)shape
{
    _shape = shape;
    [self setNeedsDisplay];
}

-(void)setNumberOfShapes:(NSUInteger)numberOfShapes
{
    _numberOfShapes = numberOfShapes;
    [self setNeedsDisplay];
}

-(void)setFaceUp:(BOOL)faceUp
{
    _faceUp = faceUp;
    [self setNeedsDisplay];
}

-(void)setMarkForCheating:(BOOL)markForCheating
{
    _markForCheating = markForCheating;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:12.0];
    [roundedRect addClip]; //prevents filling corners, i.e. sharp corners not included in roundedRect
    
    if (self.faceUp)
    {
        [[UIColor colorWithRed: 0.0 green:0.2 blue:0.4 alpha:0.1] setFill];
        UIRectFill(self.bounds);
    }
    else if(self.markForCheating)
    {
        [[UIColor yellowColor] setFill];
        UIRectFill(self.bounds);
    }
    else
    {
        [[UIColor whiteColor] setFill];
        UIRectFill(self.bounds);
    }
    
    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
    
    [self drawCards];
}
#define SYMBOL_SCALE_X 2
#define SYMBOL_SCALE_Y 7
#define SIZE_OF_OVAL_CURVE 10
#define DIAMOND_ARM_SCALE 0.8
#define Y_OFFSET_FOR_NUMBER_2 2.7
#define Y_OFFSET_FOR_NUMBER_3 1.7

- (void)drawCards
{
    if (self.shape == 1) {
        [self drawDiamond];
    } else if (self.shape == 2) {
        [self drawSquiggle];
    } else {
        [self drawOval];
    }
}



- (void)drawSquiggle
{
    CGPoint middle = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGPoint start = CGPointMake(middle.x + (middle.x / SYMBOL_SCALE_X), middle.y - (middle.y / SYMBOL_SCALE_Y));
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth =5; // ?????
    [path moveToPoint:start];
    [path addQuadCurveToPoint:CGPointMake(start.x, middle.y + (middle.y / SYMBOL_SCALE_Y)) controlPoint:CGPointMake(start.x + SIZE_OF_OVAL_CURVE, middle.y)];
    [path addCurveToPoint:CGPointMake(middle.x - (middle.x / SYMBOL_SCALE_X), middle.y + (middle.y / SYMBOL_SCALE_Y)) controlPoint1:CGPointMake(middle.x, middle.y + (middle.y / SYMBOL_SCALE_Y) + (middle.y / SYMBOL_SCALE_Y)) controlPoint2:CGPointMake(middle.x, middle.y)];
    [path addQuadCurveToPoint:CGPointMake(middle.x - (middle.x / SYMBOL_SCALE_X), start.y) controlPoint:CGPointMake(middle.x - (middle.x / SYMBOL_SCALE_X) - SIZE_OF_OVAL_CURVE, middle.y)];
    [path addCurveToPoint:CGPointMake(start.x, start.y) controlPoint1:CGPointMake(middle.x, middle.y - (middle.y / SYMBOL_SCALE_Y) - (middle.y / SYMBOL_SCALE_Y)) controlPoint2:CGPointMake(middle.x, middle.y)];
    //----------------------------
    path.lineWidth =3; // ?????
    [path closePath];
    [self drawAttributesFor:path];
}

- (void)drawOval
{
    CGPoint middle = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGPoint start = CGPointMake(middle.x + (middle.x / SYMBOL_SCALE_X), middle.y - (middle.y / SYMBOL_SCALE_Y));
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:start];
    [path addQuadCurveToPoint:CGPointMake(start.x, middle.y + (middle.y / SYMBOL_SCALE_Y)) controlPoint:CGPointMake(start.x + SIZE_OF_OVAL_CURVE, middle.y)];
    [path addLineToPoint:CGPointMake(middle.x - (middle.x / SYMBOL_SCALE_X), middle.y + (middle.y / SYMBOL_SCALE_Y))];
    [path addQuadCurveToPoint:CGPointMake(middle.x - (middle.x / SYMBOL_SCALE_X), start.y) controlPoint:CGPointMake(middle.x - (middle.x / SYMBOL_SCALE_X) - SIZE_OF_OVAL_CURVE, middle.y)];
    path.lineWidth =3; // ?????
    [path closePath];
    
    [self drawAttributesFor:path];
}

- (void)drawDiamond
{
    CGPoint middle = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGPoint start = CGPointMake(middle.x, middle.y - (middle.y / SYMBOL_SCALE_Y));
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:start];
    [path addLineToPoint:CGPointMake(middle.x + (middle.x / (SYMBOL_SCALE_X * DIAMOND_ARM_SCALE)), middle.y)];
    [path addLineToPoint:CGPointMake(middle.x, middle.y + (middle.y / SYMBOL_SCALE_Y))];
    [path addLineToPoint:CGPointMake(middle.x - (middle.x / (SYMBOL_SCALE_X * DIAMOND_ARM_SCALE)), middle.y)];
    path.lineWidth =3; // ?????
    [path closePath];
    
    [self drawAttributesFor:path];
}
- (void)drawAttributesFor:(UIBezierPath *)path
{
    //----------------------------------------
    NSArray *colorPallette = @[[UIColor redColor],[UIColor greenColor],[UIColor purpleColor]];
    UIColor *cardColor = colorPallette[self.color-1];
    //-----------------------------------------
    [cardColor setStroke];
    if (self.shade ==3 || self.shade ==2)[cardColor setFill];
    if (self.numberOfShapes == 2) {
        CGFloat yOffset = self.bounds.size.height/2/Y_OFFSET_FOR_NUMBER_2;
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -yOffset);
        [path applyTransform:transform];
        [self drawPath:path];
        
        transform = CGAffineTransformMakeTranslation(0, yOffset * 2);
        [path applyTransform:transform];
        [self drawPath:path];
        
    } else if (self.numberOfShapes == 3) {
        CGFloat yOffset = self.bounds.size.height/2/Y_OFFSET_FOR_NUMBER_3;
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -yOffset);
        [path applyTransform:transform];
        [self drawPath:path];
        
        transform = CGAffineTransformMakeTranslation(0, yOffset);
        [path applyTransform:transform];
        [self drawPath:path];
        
        transform = CGAffineTransformMakeTranslation(0, yOffset);
        [path applyTransform:transform];
        [self drawPath:path];
        
    } else {
        [self drawPath:path];
    }
}

-(void) drawPath:(UIBezierPath* )path
{
    [path stroke];
    if (self.shade ==2){
        [path fill];
        [self strip:path];}
    else {
        [path fill];}
}

void drawStripes (void *info, CGContextRef con) {
    // assume 4 x 4 cell
    CGContextSetFillColorWithColor(con, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(con, CGRectMake(0,0,4,2));
}

-(void)strip: (UIBezierPath* )path
{
    // push context so add clip is only temporary
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // add clip for this copy of the context
    [path addClip];
    
    CGColorSpaceRef sp2 = CGColorSpaceCreatePattern(nil);
    CGContextSetFillColorSpace (context, sp2);
    CGColorSpaceRelease (sp2);
    CGPatternCallbacks callback = {
        0, drawStripes, nil
    };
    CGAffineTransform tr = CGAffineTransformIdentity;
    CGPatternRef patt = CGPatternCreate(nil,
                                        CGRectMake(0,0,4,4),
                                        tr,
                                        4, 4,
                                        kCGPatternTilingConstantSpacingMinimalDistortion,
                                        true,
                                        &callback);
    CGFloat alph = 1.0;
    CGContextSetFillPattern(context, patt, &alph);
    CGPatternRelease(patt);
    CGContextFillRect(context, self.bounds);
    
    // restore context = remove clipping
    CGContextRestoreGState(context);
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
