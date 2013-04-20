//
//  TTScrollViewWrapper.m
//  UIScrollSlidingPages
//
//  The purpose of this class is purely to be a wrapper that you can put a UIScrollView inside, and it will pass all it's touch events to the UIScrollView. This is so you can turn the ClipToBounds property of the UIScrollView off (so that a paged scroller still shows items to the left and right such as in the topScroller title), but you can still drag anywhere along the ScrollViewWrapper, and the drag gets passed to the scrollView.
//
//  Created by Thomas Thorpe on 20/04/2013.
//  Copyright (c) 2013 Thomas Thorpe. All rights reserved.
//

/*
 Copyright (c) 2012 Tom Thorpe. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "TTScrollViewWrapper.h"

@implementation TTScrollViewWrapper

- (id)initWithFrame:(CGRect)frame andUIScrollView: (UIScrollView *)scroll
{
    self = [super initWithFrame:frame];
    if (self) {
        scrollView = scroll;
    }
    return self;
}

//This method means that when anything hits inside of this view, it will actually pass on the hit to scrollView instead.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event])
    {
		return scrollView;
	}
	return nil;
}


@end
