//
//  TTSlidingPagesDataSource.h
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
@class TTScrollSlidingPagesController;
@class TTSlidingPage;
@class TTSlidingPageTitle;

@protocol TTSlidingPagesDataSource <NSObject>

-(int)numberOfPagesForSlidingPagesViewController:(TTScrollSlidingPagesController *)source;

-(TTSlidingPage *)pageForSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index;
-(TTSlidingPageTitle *)titleForSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index;

@optional
/**  @method widthForPageOnSlidingPagesViewController:atIndex
 *   @brief - This should NOT be used when paging is disabled.  - An optional method to specify the width of one of your pages, if you don't want it to be the full width of the control.
 *   This should NOT be used when paging is disabled - An optional method to specify the width of one of your pages, if you don't implement this method each page will just be the width of the TTScrollSlidingPagesController view.**/
-(int)widthForPageOnSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index;


@end
