//
//  TTTriangle.h
//  UIScrollSlidingPages
//
//  Created by Thomas Thorpe on 16/04/2013.
//  Copyright (c) 2013 Thomas Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TTTriangleType) {
    TTTriangleTypeTop = 1,
    TTTriangleTypeBottom = 2,
};

@interface TTTriangle : UIView

@property (nonatomic, strong, readwrite) UIColor *color;
@property (nonatomic, assign, readwrite) TTTriangleType type;

- (id)initWithFrame:(CGRect)frame color:(UIColor *)sColor;
- (id)initWithFrame:(CGRect)frame color:(UIColor *)sColor type:(TTTriangleType)type;

@end
