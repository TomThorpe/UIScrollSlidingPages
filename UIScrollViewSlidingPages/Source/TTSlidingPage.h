//
//  TTSlidingPage.h
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

#import <Foundation/Foundation.h>

@interface TTSlidingPage : NSObject

//if your view has a controller associated with it, you should use this initialiser and pass the view controller. This will make sure it gets retained and messages are passed to it correctly. 
-(id)initWithHeaderText:(NSString *)headerText andContentViewController:(UIViewController *)contentViewController;
//if your view has a controller associated with it, you should use this initialiser and pass the view controller. This will make sure it gets retained and messages are passed to it correctly. 
-(id)initWithHeaderImage:(UIImage *)headerImage andContentViewController:(UIViewController *)contentViewController;

//if you use this method and just pass in a content view as a UIView, you must keep your own reference to the view controller, otherwise it might get deallocated and things will start going weird. Use this constructor at your own risk. 
-(id)initWithHeaderText:(NSString *)headerText andContentView:(UIView *)contentView;

//if you use this method and just pass in a content view as a UIView, you must keep your own reference to the view controller, otherwise it might get deallocated and things will start going weird. Use this constructor at your own risk. 
-(id)initWithHeaderImage:(UIImage *)headerImage andContentView:(UIView *)contentView;

//The title text to go in the nav bar
@property(strong, nonatomic) NSString *headerText;

//An image to use in the nav bar (if you set this, the title text will not be used)
@property(strong, nonatomic) UIImage *headerImage;

//the view controller for the content area. Preferbale to just setting a view, as it will make sure the correct view controller heirarchy gets maintained, and that the viewcontroller doesnt get deallocated.
@property(strong, nonatomic) UIViewController *contentViewController;

//The view to go in the content area. You should only use this if you are keeping your own reference to the view controller. Use at your own risk.
@property(strong, nonatomic) UIView *contentView;

@end
