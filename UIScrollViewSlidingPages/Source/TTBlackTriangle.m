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
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)sColor
{
    color = sColor;
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
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

@end
