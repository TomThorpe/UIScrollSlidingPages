//
//  TTTriangle.m
//  UIScrollSlidingPages
//
//  Created by Thomas Thorpe on 16/04/2013.
//  Copyright (c) 2013 Thomas Thorpe. All rights reserved.
//

#import "TTTriangle.h"

@implementation TTTriangle

- (id)initWithFrame:(CGRect)frame color:(UIColor *)sColor type:(TTTriangleType)type {
    self = [super initWithFrame:frame];
    if (self) {
        _color = sColor;
        _type = type;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)sColor
{
    return [self initWithFrame:frame color:sColor type:TTTriangleTypeTop];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame color:[UIColor whiteColor] type:TTTriangleTypeTop];
}

#pragma mark - Setters / Getters

- (void)setColor:(UIColor *)color {
    _color = color;

    [self setNeedsDisplay];
}

- (void)setType:(TTTriangleType)type {
    _type = type;

    [self setNeedsDisplay];
}

#pragma mark - Drawing

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(ctx, rect);
    
    CGContextBeginPath(ctx);
    if (_type == TTTriangleTypeTop) {
        CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // top right
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));  // mid bottom
    } else if (_type == TTTriangleTypeBottom) {
        CGContextMoveToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    }
    CGContextClosePath(ctx);
    
    CGContextSetFillColorWithColor(ctx, _color.CGColor);
    CGContextFillPath(ctx);
}

@end
