//
//  TTSlidingPagesController.h
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

#import <UIKit/UIKit.h>
#import "TTSlidingPagesDataSource.h"
#import "TTSliddingPageDelegate.h"

@class TTScrollViewWrapper;

@interface TTScrollSlidingPagesController : UIViewController<UIScrollViewDelegate>{
    int currentPageBeforeRotation;
    bool viewDidLoadHasBeenCalled;
    bool viewDidAppearHasBeenCalled;
    UIPageControl *pageControl;
    TTScrollViewWrapper *topScrollViewWrapper;
    UIScrollView *bottomScrollView, *topScrollView;
}


-(void)didRotate;
/**Don't use anything above this. Feel free to use anything below!*/


-(void)reloadPages;
-(void)scrollToPage:(int)page animated:(BOOL)animated;
-(int)getCurrentDisplayedPage;
-(int)getXPositionOfPage:(int)page;



@property (nonatomic, weak) id<TTSlidingPagesDataSource> dataSource;

@property (nonatomic, weak) id<TTSliddingPageDelegate> delegate;

/** @property titleScrollerHidden
 *  @brief Whether the title scroller bar is hidden or not.
 *  Whether the title scroller bar is hidden or not. Set this to YES if you only want the pages, and don't want the titles at the top of the page. For now even if this is set to YES you will still need to implement the `-(TTSlidingPageTitle *)titleForSlidingPagesViewController:(TTScrollSlidingPagesController *)source atIndex:(int)index` method in your datasource class, but you can just return nil for everything. Default is NO.  **/
@property (nonatomic) bool titleScrollerHidden;

/**  @property titleScrollerHeight
 *   @brief The height of the top scroller
 *   The height of the top navigation scroller (the one with the header texts or images in). If not set, this will default to 50px.  **/
@property (nonatomic) int titleScrollerHeight;

/**  @property titleScrollerItemWidth
 *   @brief The width of each item in the top scroller
 *   The width of each individual item in the top scroller. The wider it is, the less of the previous and next items you'll see, the narrower it is the more of the previous and next items you'll see but the more likely you won't have enough width for your title! Default if not set is 150px  **/
@property (nonatomic) int titleScrollerItemWidth;

/**  @property titleScrollerBackgroundColour
 *   @brief The background colour of the top scroller
 *   The background colour of the top scroller. If you want it to be a texture image, you can use [UIColor colorWithPatternImage]. If not set, the default is a black diamonds pattern (credit: from http://subtlepatterns.com/ as long as you copy the diagmonds.png files within the Images folder in the same folder as this source). **/
@property (nonatomic, strong) UIColor *titleScrollerBackgroundColour;

/**  @property titleScrollerBackgroundColour
 *   @brief The colour of the text in the top scroller
 *   The colour of the text in the top scroller. If not set, the default will be white. **/
@property (nonatomic, strong) UIColor *titleScrollerTextColour;

/**  @property triangleBackgroundColour
 *   @brief The colour of the triangle in the top scroller
 *   The colour of the triangle in the top scroller. If not set, the default will be black. **/
@property (nonatomic, strong) UIColor *triangleBackgroundColour;

/**  @property disableTopScrollerShadow
 *   @brief Disables the shadow effect on the top header scroller
 *   If set to YES the shadow effect on the top header scroller will be disabled. Default is NO. **/
@property (nonatomic) BOOL disableTitleScrollerShadow;

/**  @property disableUIPageControl
 *   @brief Disables the UIPageControl (the page dots) at the top of the screen
 *   If set to YES the UIPageControl at the top of the screen will not be added. Default is NO. **/
@property (nonatomic) BOOL disableUIPageControl;

/**  @property initialPageNumber
 *   @brief Sets the scroller to scroll to a specific page initially
 *   Sets the scroller to scroll to a specific page initially (either on the first load, or afrer calling reloadPages). Default is 0. **/
@property (nonatomic) int initialPageNumber;

/**  @property pagingEnabled
 *   @brief Whether the content view "snaps" to each page. Dont set this to NO if you implement widthForPageOnSlidingPagesViewController:atIndex in the delegate as it won't work properly!
 *   Whether the content view "snaps" to each page (YES), or if the scroll is continous (NO). Default is YES. **/
@property (nonatomic) BOOL pagingEnabled;

/**  @property zoomOutAnimationDisabled
 *   @brief Whether the "zoom out" effect that happens as you scroll from page to page should be disabled. Default is NO.
 *   Whether the "zoom out" effect that happens as you scroll from page to page should be disabled. Default is NO **/
@property (nonatomic) bool zoomOutAnimationDisabled;

/**  @property hideStatusBarWhenScrolling
 *   @brief Intended for use in iOS7+ and when the UIScrollSlidingPages control is full screen. 
 
    The new behaviour of iOS7 can result in the status bar overlapping the top of the UIScrollSlidingPages. If you set this property to YES, the page dots at the top of the screen will be hidden until the user starts scrolling, at which point the status bar is replaced with the page number dots until the user stops scrolling. 
 
    If you set this to YES, you also need to add the "UIViewControllerBasedStatusBarAppearance" key as a BOOLEAN in info.plist and set it to NO, the app will throw an exception to alert you of this if you don't.  
 
    If you use this in anything less than iOS7 it won't make sense unless in your view hierarchy you make sure the status bar overlaps the TTScrollSlidingPagesController. So unless you do that, it's probably best to enable this property conditionally if the device is iOS7+
 
 *   Default is NO
 **/
@property (nonatomic) bool hideStatusBarWhenScrolling;



@end
