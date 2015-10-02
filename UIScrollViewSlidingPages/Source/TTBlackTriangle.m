//
//  TTBlackTriangle.m
//  UIScrollSlidingPages
//
//  Created by Thomas Thorpe on 16/04/2013.
//  Copyright (c) 2013 Thomas Thorpe. All rights reserved.
//

#import "TTBlackTriangle.h"

@implementation TTBlackTriangle
{
    UIColor * color;
    BOOL shouldBeSquare;
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)sColor
{
    color = sColor;
    shouldBeSquare = NO;
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    shouldBeSquare = NO;
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)sColor shouldBeSquare:(BOOL)square {
    color = sColor;
    shouldBeSquare = YES;
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:color];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    if (shouldBeSquare == NO) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextClearRect(ctx, rect);
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // top right
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));  // mid bottom
        CGContextClosePath(ctx);
        
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillPath(ctx);
    }
}

@end
