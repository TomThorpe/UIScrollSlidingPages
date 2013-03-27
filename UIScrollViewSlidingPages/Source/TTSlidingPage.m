//
//  TTSlidingPage.m
//  UIScrollViewSlidingPages
//
//  Created by Thomas Thorpe on 27/03/2013.
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

#import "TTSlidingPage.h"

@implementation TTSlidingPage

-(id)initWithHeaderText:(NSString *)headerText andContentViewController:(UIViewController *)contentViewController
{
    self = [super init];
    if(self)
    {
        self.headerText = headerText;
        self.contentViewController = contentViewController;
        self.headerImage = nil;
    }
    return (self);
}

-(id)initWithHeaderImage:(UIImage *)headerImage andContentViewController:(UIViewController *)contentViewController
{
    self = [super init];
    if(self)
    {
        self.headerImage = headerImage;
        self.contentViewController = contentViewController;
        self.headerText = nil;
    }
    return (self);
}

-(id)initWithHeaderText:(NSString *)headerText andContentView:(UIView *)contentView
{
    self = [super init];
    if(self)
    {
        self.headerText = headerText;
        self.contentView = contentView;
        self.headerImage = nil;
    }
    return (self);
}

-(id)initWithHeaderImage:(UIImage *)headerImage andContentView:(UIView *)contentView
{
    self = [super init];
    if(self)
    {
        self.headerImage = headerImage;
        self.contentView = contentView;
        self.headerText = nil;
    }
    return (self);
}

-(void)setContentViewController:(UIViewController *)contentViewController{
    _contentViewController = contentViewController;
    if (contentViewController != nil){
        self.contentView = contentViewController.view;
    }
}

@end
