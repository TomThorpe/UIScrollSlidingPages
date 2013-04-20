//
//  TTScrollViewWrapper.h
//  UIScrollSlidingPages
//
//  Created by Thomas Thorpe on 20/04/2013.
//  Copyright (c) 2013 Thomas Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTScrollViewWrapper : UIView{
    UIScrollView *scrollView;
}

- (id)initWithFrame:(CGRect)frame andUIScrollView: (UIScrollView *)scroll;

@end
