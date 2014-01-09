//
//  TTSlidingPagesController.m
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

#import "TTScrollSlidingPagesController.h"
#import "TTSlidingPage.h"
#import "TTSlidingPageTitle.h"
#import <QuartzCore/QuartzCore.h>
#import "TTBlackTriangle.h"
#import "TTScrollViewWrapper.h"

@interface TTScrollSlidingPagesController ()

@end

@implementation TTScrollSlidingPagesController

/**
 Initalises the control and sets all the default values for the user-settable properties.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        viewDidLoadHasBeenCalled = NO;
        //set defaults
        self.titleScrollerHidden = NO;
        self.titleScrollerHeight = 50;
        self.titleScrollerItemWidth = 150;
        
        UIImage *backgroundImage = [UIImage imageNamed:@"diagmonds.png"];
        if (backgroundImage != nil){
            self.titleScrollerBackgroundColour = [UIColor colorWithPatternImage:backgroundImage];
        } else {
            self.titleScrollerBackgroundColour = [UIColor blackColor];
        }
        
        self.titleScrollerTextColour = [UIColor whiteColor];
        self.triangleBackgroundColour = [UIColor blackColor];
        self.disableTitleScrollerShadow = NO;
        self.disableUIPageControl = NO;
        self.initialPageNumber = 0;
        self.pagingEnabled = YES;
        self.zoomOutAnimationDisabled = NO;
        self.hideStatusBarWhenScrolling = NO;
    }
    return self;
}

/**
 Initialse the top and bottom scrollers (but don't populate them with pages yet)
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewDidLoadHasBeenCalled = YES;
    
    int nextYPosition = 0;
    int pageDotsControlHeight = 0;
    if (!self.disableUIPageControl){
        //create and add the UIPageControl
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        int statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width); // the height of the status bar will be the smaller value. Can't guarantee it's the height property because if the app starts in landscape sometimes the height is actually the width property :|
        pageDotsControlHeight = statusBarHeight;
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, nextYPosition, self.view.frame.size.width, pageDotsControlHeight)];
        pageControl.backgroundColor = [UIColor blackColor];
        pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [pageControl addTarget:self action:@selector(pageControlChangedPage:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:pageControl];
        nextYPosition += pageDotsControlHeight;
    }
    
    TTBlackTriangle *triangle;
    if (!self.titleScrollerHidden){
        //add a triangle view to point to the currently selected page from the header
        int triangleWidth = 30;
        int triangleHeight = 10;
        triangle = [[TTBlackTriangle alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-(triangleWidth/2), nextYPosition/*start at the top of the nextYPosition, but dont increment the yposition, so this means the triangle sits on top of the topscroller and cuts into it a bit*/, triangleWidth, triangleHeight) color:self.triangleBackgroundColour];
        triangle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:triangle];
        
        //set up the top scroller (for the nav titles to go in) - it is one frame wide, but has clipToBounds turned off to enable you to see the next and previous items in the scroller. We wrap it in an outer uiview so that the background colour can be set on that and span the entire view (because the width of the topScrollView is only one frame wide and centered).
        topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.titleScrollerItemWidth, self.titleScrollerHeight)];
        topScrollView.center = CGPointMake(self.view.center.x, topScrollView.center.y); //center it horizontally
        topScrollView.pagingEnabled = YES;
        topScrollView.clipsToBounds = NO;
        topScrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        topScrollView.showsVerticalScrollIndicator = NO;
        topScrollView.showsHorizontalScrollIndicator = NO;
        topScrollView.directionalLockEnabled = YES;
        topScrollView.backgroundColor = [UIColor clearColor];
        topScrollView.pagingEnabled = self.pagingEnabled;
        topScrollView.delegate = self; //move the bottom scroller proportionally as you drag the top.
        topScrollViewWrapper = [[TTScrollViewWrapper alloc] initWithFrame:CGRectMake(0, nextYPosition, self.view.frame.size.width, self.titleScrollerHeight) andUIScrollView:topScrollView];//make the view to put the scroll view inside which will allow the background colour, and allow dragging from anywhere in this wrapper to be passed to the scrollview.
        topScrollViewWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        topScrollViewWrapper.backgroundColor = self.titleScrollerBackgroundColour;
        //pass touch events from the wrapper onto the scrollview (so you can drag from the entire width, as the scrollview itself only lives in the very centre, but with clipToBounds turned off)
        
        //single tap to switch to different item
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topScrollViewTapped:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [topScrollViewWrapper addGestureRecognizer: singleTap];
        
        [topScrollViewWrapper addSubview:topScrollView];//put the top scroll view in the wrapper.
        [self.view addSubview:topScrollViewWrapper]; //put the wrapper in this view.
        nextYPosition += self.titleScrollerHeight;
    }
    
    
    //set up the bottom scroller (for the content to go in)
    bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, nextYPosition, self.view.frame.size.width, self.view.frame.size.height-nextYPosition)];
    bottomScrollView.pagingEnabled = self.pagingEnabled;
    bottomScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    bottomScrollView.showsVerticalScrollIndicator = NO;
    bottomScrollView.showsHorizontalScrollIndicator = NO;
    bottomScrollView.directionalLockEnabled = YES;
    bottomScrollView.delegate = self; //move the top scroller proportionally as you drag the bottom.
    bottomScrollView.alwaysBounceVertical = NO;
    [self.view addSubview:bottomScrollView];
    
    //add the drop shadow on the top scroller (if enabled) and bring the view to the front
    if (!self.titleScrollerHidden && !self.disableTitleScrollerShadow){
        topScrollViewWrapper.layer.masksToBounds = NO;
        topScrollViewWrapper.layer.shadowOffset = CGSizeMake(0, 4);
        topScrollViewWrapper.layer.shadowRadius = 4;
        topScrollViewWrapper.layer.shadowOpacity = 0.3;
        
        //Add shadow path (better performance)
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:topScrollViewWrapper.bounds].CGPath;
        [topScrollViewWrapper.layer setShadowPath:shadowPath];
        //rasterize (also due to the better performance)
        topScrollViewWrapper.layer.shouldRasterize = YES;
        topScrollViewWrapper.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        [self.view bringSubviewToFront:topScrollViewWrapper];//bring view to sit on top so you can see the shadow!
    }
    
    if (triangle != nil){
        [self.view bringSubviewToFront:triangle];
    }
    
    if (self.hideStatusBarWhenScrolling){
        //hide the page dots initially
        pageControl.alpha = 0;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if (!viewDidAppearHasBeenCalled){
        viewDidAppearHasBeenCalled = YES;
        [self reloadPages];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Goes through the datasource and finds all the pages, then populates the topScrollView and bottomScrollView with all the pages and headers.
 
 It clears any of the views in both scrollViews first, so if you need to reload all the pages with new data from the dataSource for some reason, you can call this method.
 */
-(void)reloadPages{
    if (self.dataSource == nil){
        [NSException raise:@"TTSlidingPagesController data source missing" format:@"There was no data source set for the TTSlidingPagesControlller. You must set the .dataSource property on TTSlidingPagesController to an object instance that implements TTSlidingPagesDataSource, also make sure you do this before the view will be loaded (so before you add it as a subview to any other view that is about to appear)"];
    }
    
    //remove any existing items from the subviews
    [topScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [bottomScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //remove any existing items from the view hierarchy
    for (UIViewController* subViewController in self.childViewControllers){
        [subViewController willMoveToParentViewController:nil];
        [subViewController removeFromParentViewController];
    }
    
    //get the number of pages
    int numOfPages = [self.dataSource numberOfPagesForSlidingPagesViewController:self];
    
    //keep track of where next to put items in each scroller
    int nextXPosition = 0;
    int nextTopScrollerXPosition = 0;
    
    //loop through each page and add it to the scroller
    for (int i=0; i<numOfPages; i++){
        //top scroller (nav) add----
        TTSlidingPageTitle *title = [self.dataSource titleForSlidingPagesViewController:self atIndex:i];
        UIView *topItem;
        if (title == nil){
            //do nothing, just empty view
            NSLog(@"TTScrollSlidingPagesController Notice: An empty title object was returned in the titleForSlidingPagesViewController method of the datasource. Titles should be instances of TTSlidingPageTitle. An empty view is being put in it's place.");
            topItem = [[UIView alloc] init];
        } else if (![title isKindOfClass:[TTSlidingPageTitle class]]){ //if someone has implemented the datasource wrong tell them
            [NSException raise:@"TTScrollSlidingPagesController Wrong Title Type" format:@"TTScrollSlidingPagesController: Titles should be instances of TTSlidingPageTitle, one was returned that wasn't a TTSlidingPageTitle. Did you implement the titleForSlidingPagesViewController method in the datasource correctly and with the right return type?"];
        }
        else if (title.headerImage != nil){
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = title.headerImage;
            topItem = (UIView *)imageView;
        } else {
            UILabel *label = [[UILabel alloc] init];
            label.text = title.headerText;
            label.textAlignment = NSTextAlignmentCenter;
            label.adjustsFontSizeToFitWidth = YES;
            label.textColor = self.titleScrollerTextColour;
            label.font = [UIFont boldSystemFontOfSize:19];
            label.backgroundColor = [UIColor clearColor];
            
            //add subtle drop shadow
            label.layer.shadowColor = [[UIColor blackColor] CGColor];
            label.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
            label.layer.shadowRadius = 2.0f;
            label.layer.shadowOpacity = 1.0f;
            
            //set view as the top item
            topItem = (UIView *)label;
        }
        topItem.frame = CGRectMake(nextTopScrollerXPosition, 0, topScrollView.frame.size.width, topScrollView.frame.size.height);
        [topScrollView addSubview:topItem];
        nextTopScrollerXPosition = nextTopScrollerXPosition + topItem.frame.size.width;
        
        
        //bottom scroller add-----
        //set the default width of the page
        int pageWidth = bottomScrollView.frame.size.width;
        //if the datasource implements the widthForPageOnSlidingPagesViewController:atIndex method, use it to override the width of the page
        if ([self.dataSource respondsToSelector:@selector(widthForPageOnSlidingPagesViewController:atIndex:)] ){
            pageWidth = [self.dataSource widthForPageOnSlidingPagesViewController:self atIndex:i];
        }
        
        TTSlidingPage *page = [self.dataSource pageForSlidingPagesViewController:self atIndex:i];//get the page
        if (page == nil || ![page isKindOfClass:[TTSlidingPage class]]){
            [NSException raise:@"TTScrollSlidingPagesController Wrong Page Content Type" format:@"TTScrollSlidingPagesController: Page contents should be instances of TTSlidingPage, one was returned that was either nil, or wasn't a TTSlidingPage. Make sure your pageForSlidingPagesViewController method in the datasource always returns a TTSlidingPage instance for each page requested."];
        }
        UIView *contentView = page.contentView;
        
        //make a container view (putting it inside a container view because if the contentView uses any autolayout it doesn't work well with the .transform property that the zoom animation uses. The container view shields it from this).
        UIView *containerView = [[UIView alloc] init];
        
        //put the container view in the right position, y is always 0, x is incremented with each item you add (it is a horizontal scroller).
        containerView.frame = CGRectMake(nextXPosition, 0, pageWidth, bottomScrollView.frame.size.height);
        nextXPosition = nextXPosition + containerView.frame.size.width;
        
        //put the content view inside the container view
        [containerView addSubview:contentView];
        
        //add the container view to the scroll view
        [bottomScrollView addSubview:containerView];
        
        
        if (page.contentViewController != nil){
            [self addChildViewController:page.contentViewController];
            [page.contentViewController didMoveToParentViewController:self];
        }
        
    }
    
    //now set the content size of the scroller to be as wide as nextXPosition (we can know that nextXPosition is also the width of the scroller)
    topScrollView.contentSize = CGSizeMake(nextTopScrollerXPosition, topScrollView.frame.size.height);
    bottomScrollView.contentSize = CGSizeMake(nextXPosition, bottomScrollView.frame.size.height);
    
    int initialPage = self.initialPageNumber;
    
    if (!self.disableUIPageControl){
        //set the number of dots on the page control, and set the initial selected dot
        pageControl.numberOfPages = numOfPages;
        pageControl.currentPage = initialPage;
    }
    
    //scroll to the initialpage
    [self scrollToPage:initialPage animated:NO];
}


/**
 Gets number of the page currently displayed in the bottom scroller (zero based - so starting at 0 for the first page).
 
 @return Returns the number of the page currently displayed in the bottom scroller (zero based - so starting at 0 for the first page).
 */
-(int)getCurrentDisplayedPage{
    //sum through all the views until you get to a position that matches the offset then that's what page youre on (each view can be a different width)
    int page = 0;
    int currentXPosition = 0;
    while (currentXPosition <= bottomScrollView.contentOffset.x && currentXPosition < bottomScrollView.contentSize.width){
        currentXPosition += [self getWidthOfPage:page];
        
        if (currentXPosition <= bottomScrollView.contentOffset.x){
            page++;
        }
    }
    
    return page;
}

/**
 Gets the x position of the requested page in the bottom scroller. For example, if you ask for page 5, and page 5 starts at the contentOffset 520px in the bottom scroller, this will return 520.
 
 @param page The page number requested.
 @return Returns the x position of the requested page in the bottom scroller
 */
-(int)getXPositionOfPage:(int)page{
    //each view could in theory have a different width
    int currentTotal = 0;
    for (int curPage = 0; curPage < page; curPage++){
        currentTotal += [self getWidthOfPage:curPage];
    }
    
    return currentTotal;
}

/**
 Gets the width of a specific page in the bottom scroll view. Most of the time this will be the width of the scrollview itself, but if you have widthForPageOnSlidingPagesViewController implemented on the datasource it might be different - hence this method.
 
 @param page The page number requested.
 @return Returns the width of the page requested.
 */
-(int)getWidthOfPage:(int)page {
    int pageWidth = bottomScrollView.frame.size.width;
    if ([self.dataSource respondsToSelector:@selector(widthForPageOnSlidingPagesViewController:atIndex:)]){
        pageWidth = [self.dataSource widthForPageOnSlidingPagesViewController:self atIndex:page];
    }
    return pageWidth;
}

/**
 Gets the page based on an X position in the topScrollView. For example, if you pass in 100 and each topScrollView width is 50, then this would return page 2.
 
 @param page The X position in the topScrollView
 @return Returns the page. For example, if you pass in 100 and each topScrollView width is 50, then this would return page 2.
 */
-(int)getTopScrollViewPageForXPosition:(int)xPosition{
    return xPosition / self.titleScrollerItemWidth;
}

/**
 Scrolls the bottom scorller (content scroller) to a particular page number.
 
 @param page The page number to scroll to.
 @param animated Whether the scroll should be animated to move along to the page (YES) or just directly scroll to the page (NO)
 */
-(void)scrollToPage:(int)page animated:(BOOL)animated{
    //keep track of the current page (for the rotation if it ever happens)
    currentPageBeforeRotation = page;
    
    //scroll to the page
    [bottomScrollView setContentOffset: CGPointMake([self getXPositionOfPage:page],0) animated:animated];
    
    if (!animated){
        //if the scroll is not animated, we also need to move the topScrollView - we don't want (if it's animated, it'll call the scrollViewDidScroll delegate which keeps everything in sync, so calling it twice would mess things up).
        [topScrollView setContentOffset: CGPointMake(page * topScrollView.frame.size.width, 0) animated:animated];
    }
    
    //update the pagedots pagenumber
    if (!self.disableUIPageControl){
        pageControl.currentPage = page;
    }
}




/**
 Handler for the gesture recogniser on the top scrollview wrapper. When the topscrollview wrapper is tapped, this works out the tap position and scrolls the view to that page.
 */
- (void)topScrollViewTapped:(id)sender {
    //get the point that was tapped within the context of the topScrollView (not the wrapper)
    CGPoint point = [sender locationInView:topScrollView];
    
    //we need to add on the contentOffset of the topScrollView
    //int position = point.x + topScrollView.contentOffset.x;
    
    //find out what page in the topscroller would be at that x location
    int page = [self getTopScrollViewPageForXPosition:point.x];
    
    //if not already on the page and the page is within the bounds of the pages we have, scroll to the page!
    if ([self getCurrentDisplayedPage] != page && page < [bottomScrollView.subviews count]){
        [self scrollToPage:page animated:YES];
    }
    
}

/**If YES, hides the status bar and shows the page dots.
 *If NO, shows the status bar and hides the page dots.
 But only if the self.hideStatusBarWhenScrolling property is set to YES, and the disableUIPageControl is NO.
 */
-(void)setStatusBarReplacedWithPageDots:(BOOL)statusBarHidden{
    if (self.hideStatusBarWhenScrolling && !self.disableUIPageControl){
        //hide the status bar and show the page dots control
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden withAnimation:UIStatusBarAnimationFade];
        float pageControlAlpha = statusBarHidden ? 1 : 0;
        [UIView animateWithDuration:0.3 animations:^{
            pageControl.alpha = pageControlAlpha;
        }];
    }
}


#pragma mark Some delegate methods for handling rotation.

-(void)didRotate{
    currentPageBeforeRotation = [self getCurrentDisplayedPage];
}


-(void)viewDidLayoutSubviews{
    //this will get called when the screen rotates, at which point we need to fix the frames of all the subviews to be the new correct x position horizontally. The autolayout mask will automatically change the width for us.
    
    if (!self.titleScrollerHidden && !self.disableTitleScrollerShadow){
        //Fix the shadow path now the bounds might have changed.
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:topScrollViewWrapper.bounds].CGPath;
        [topScrollViewWrapper.layer setShadowPath:shadowPath];
    }
    
    //reposition the subviews and set the new contentsize width
    CGRect frame;
    int nextXPosition = 0;
    int page = 0;
    for (UIView *view in bottomScrollView.subviews) {
        view.transform = CGAffineTransformIdentity;
        frame = view.frame;
        frame.size.width = [self getWidthOfPage:page];
        frame.size.height = bottomScrollView.frame.size.height;
        frame.origin.x = nextXPosition;
        frame.origin.y = 0;
        page++;
        nextXPosition += frame.size.width;
        view.frame = frame;
    }
    bottomScrollView.contentSize = CGSizeMake(nextXPosition, bottomScrollView.frame.size.height);
    
    //set it back to the same page as it was before (the contentoffset will be different now the widths are different)
    int contentOffsetWidth = [self getXPositionOfPage:currentPageBeforeRotation];
    bottomScrollView.contentOffset = CGPointMake(contentOffsetWidth, 0);
    
}

#pragma mark UIScrollView delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self setStatusBarReplacedWithPageDots:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (bottomScrollView.subviews.count == 0){
        return; //there are no pages in the bottom scroll view so we couldn't have scrolled. This probably happened during a rotation before the pages had been created (E.g if the app starts in landscape mode)
    }
    
    int currentPage = [self getCurrentDisplayedPage];
    
    if (!self.zoomOutAnimationDisabled){
        //Do a zoom out effect on the current view and next view depending on the amount scrolled
        double minimumZoom = 0.93;
        double zoomSpeed = 1000;//increase this number to slow down the zoom
        UIView *currentView = [bottomScrollView.subviews objectAtIndex:currentPage];
        UIView *nextView;
        if (currentPage < [bottomScrollView.subviews count]-1){
            nextView = [bottomScrollView.subviews objectAtIndex:currentPage+1];
        }
        
        //currentView zooms out as scroll left
        int distanceFromPageOrigin = bottomScrollView.contentOffset.x - [self getXPositionOfPage:currentPage]; //find out how far the scroll is away from the start of the page, and use this to adjust the transform of the currentView
        if (distanceFromPageOrigin < 0) {distanceFromPageOrigin = 0;}
        double scaleAmount = 1-(distanceFromPageOrigin/zoomSpeed);
        if (scaleAmount < minimumZoom ){scaleAmount = minimumZoom;}
        currentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleAmount, scaleAmount);
        
        //nextView zooms in as scroll left
        if (nextView != nil){
            //find out how far the scroll is away from the start of the next page, and use this to adjust the transform of the nextView
            distanceFromPageOrigin = (bottomScrollView.contentOffset.x - [self getXPositionOfPage:currentPage+1]) * -1;//multiply by minus 1 to get the distance to the next page (because otherwise the result would be -300 for example, as in 300 away from the next page)
            if (distanceFromPageOrigin < 0) {distanceFromPageOrigin = 0;}
            scaleAmount = 1-(distanceFromPageOrigin/zoomSpeed);
            if (scaleAmount < minimumZoom ){scaleAmount = minimumZoom;}
            nextView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleAmount, scaleAmount);
        }
    }
    
    
    if (scrollView == topScrollView){
        //translate the top scroll to the bottom scroll
        
        //get the page number of the scroll item (e.g third header = 3rd page).
        int pageNumber =  [self getTopScrollViewPageForXPosition:topScrollView.contentOffset.x];
        
        //get the width of the bottom scroller item at that page
        int bottomPageWidth = [self getWidthOfPage:pageNumber];
        
        //work out the start of that page number in the bottom scroller (e.g if the 3rd bottom scroller page starts at 520px, then it's 520)
        int bottomPageStart = [self getXPositionOfPage:pageNumber];
        
        //work out the percent through the header you have scrolled in the top scroller
        int startOfTopPage = pageNumber * self.titleScrollerItemWidth;
        float percentOfTop = (topScrollView.contentOffset.x - startOfTopPage) / self.titleScrollerItemWidth;
        
        //translate that to the percent through the bottom scroller page to scroll, by doing the (percent through the top header * the bottom width) + the bottomPageStart.
        int bottomScrollOffset = (percentOfTop * bottomPageWidth) + bottomPageStart;
        
        bottomScrollView.delegate = nil;
        bottomScrollView.contentOffset = CGPointMake(bottomScrollOffset, 0);
        bottomScrollView.delegate = self;
    }
    else if (scrollView == bottomScrollView){
        //translate the bottom scroll to the top scroll. The bottom scroll items can in theory be different widths so it's a bit more complicated.
        
        //get the x position of the page in the top scroller
        int topXPosition = self.titleScrollerItemWidth * currentPage;
        
        //work out the percentage past this page the view currently is, by getting the xPosition of the next page and seeing how close it is
        float currentPageStartXPosition = [self getXPositionOfPage:currentPage]; //subtract the current page's start x position from both the current offset and next page's start position, to mean that we're on a base level. So for example if we're on page 1 so that the currentPageStartXPosition is 320, and the current offset is 330, the next page xPosition is 640, then 330-320 - 10, and 640-320 - 320. So we're 10 pixels into 320, so roughly 3%.
        float nextPagesXPosition = [self getXPositionOfPage:currentPage+1];
        float percentageTowardsNextPage = (scrollView.contentOffset.x-currentPageStartXPosition) / (nextPagesXPosition-currentPageStartXPosition);
        //multiply the percentage towards the next page that you are, by the width of each topScroller item, and add it to the topXPosition
        
        float addToTopXPosition = percentageTowardsNextPage * self.titleScrollerItemWidth;
        topXPosition = topXPosition + roundf(addToTopXPosition);
        
        topScrollView.delegate = nil;
        topScrollView.contentOffset = CGPointMake(topXPosition, 0);
        topScrollView.delegate = self;
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int currentPage = [self getCurrentDisplayedPage];
    
    [self setStatusBarReplacedWithPageDots:NO];
    
    //store the page you were on so if you have a rotate event, or you come back to this view you know what page to start at. (for example from a navigation controller), the viewDidLayoutSubviews method will know which page to navigate to (for example if the screen was portrait when you left, then you changed to landscape, and navigate back, then viewDidLayoutSubviews will need to change all the sizes of the views, but still know what page to set the offset to)
    currentPageBeforeRotation = [self getCurrentDisplayedPage];
    
    
    //update the pagedots pagenuber
    if (!self.disableUIPageControl){
        //set the correct page on the pagedots
        pageControl.currentPage = currentPage;
    }
  
    //call the delegate to tell him you've scrolled to another page
    if([self.delegate respondsToSelector:@selector(didScrollToViewAtIndex:)]){
      [self.delegate didScrollToViewAtIndex:currentPage];
    }
  
    /*Just do a quick check, that if the paging enabled property is YES (paging is enabled), the user should not define widthForPageOnSlidingPagesViewController on the datasource delegate because scrollviews do not cope well with paging being enabled for scrollviews where each subview is not full width! */
    if (self.pagingEnabled == YES && [self.dataSource respondsToSelector:@selector(widthForPageOnSlidingPagesViewController:atIndex:)]){
        NSLog(@"Warning: TTScrollSlidingPagesController. You have paging enabled in the TTScrollSlidingPagesController (pagingEnabled is either not set, or specifically set to YES), but you have also implemented widthForPageOnSlidingPagesViewController:atIndex:. ScrollViews do not cope well with paging being disabled when items have custom widths. You may get weird behaviour with your paging, in which case you should either disable paging (set pagingEnabled to NO) and keep widthForPageOnSlidingPagesViewController:atIndex: implented, or not implement widthForPageOnSlidingPagesViewController:atIndex: in your datasource for the TTScrollSlidingPagesController instance.");
    }
}

#pragma mark UIPageControl page changed listener we set up on it
-(void)pageControlChangedPage:(id)sender
{
    //if not already on the page and the page is within the bounds of the pages we have, scroll to the page!
    int page = pageControl.currentPage;
    if ([self getCurrentDisplayedPage] != page && page < [bottomScrollView.subviews count]){
        [self scrollToPage:page animated:YES];
    }
}

#pragma mark property setters - for when need to do fancy things as well as set the value

-(void)setDataSource:(id<TTSlidingPagesDataSource>)dataSource{
    _dataSource = dataSource;
//    if (self.isViewLoaded){
//        [self reloadPages];
//    }
}

-(void)setPagingEnabled:(BOOL)pagingEnabled{
    _pagingEnabled = pagingEnabled;
    if (bottomScrollView != nil){
        bottomScrollView.pagingEnabled = pagingEnabled;
    }
}

#pragma mark Setters for properties to warn someone if they attempt to set a property after viewDidLoad has already been called (they won't work if so!)
-(void)raiseErrorIfViewDidLoadHasBeenCalled{
    if (viewDidLoadHasBeenCalled)
    {
        [NSException raise:@"TTSlidingPagesController set custom property too late" format:@"The app attempted to set one of the custom properties on TTSlidingPagesController (such as TitleScrollerHeight, TitleScrollerItemWidth etc.) after viewDidLoad has already been loaded. This won't work, you need to set the properties before viewDidLoad has been called - so before you access the .view property or set the dataSource. It is best to set the custom properties immediately after calling init on TTSlidingPagesController"];
    }
}
-(void)setTitleScrollerHidden:(bool)titleScrollerHidden{
    [self raiseErrorIfViewDidLoadHasBeenCalled];
    _titleScrollerHidden = titleScrollerHidden;
}
-(void)setTitleScrollerHeight:(int)titleScrollerHeight{
    [self raiseErrorIfViewDidLoadHasBeenCalled];
    _titleScrollerHeight = titleScrollerHeight;
}
-(void)setTitleScrollerItemWidth:(int)titleScrollerItemWidth{
    [self raiseErrorIfViewDidLoadHasBeenCalled];
    _titleScrollerItemWidth = titleScrollerItemWidth;
}
-(void)setTitleScrollerBackgroundColour:(UIColor *)titleScrollerBackgroundColour{
    [self raiseErrorIfViewDidLoadHasBeenCalled];
    _titleScrollerBackgroundColour = titleScrollerBackgroundColour;
}
-(void)setTriangleBackgroundColour:(UIColor *)triangleBackgroundColour{
    [self raiseErrorIfViewDidLoadHasBeenCalled];
    _triangleBackgroundColour = triangleBackgroundColour;
}
-(void)setTitleScrollerTextColour:(UIColor *)titleScrollerTextColour{
    [self raiseErrorIfViewDidLoadHasBeenCalled];
    _titleScrollerTextColour = titleScrollerTextColour;
}
-(void)setDisableTitleScrollerShadow:(BOOL)disableTitleScrollerShadow{
    [self raiseErrorIfViewDidLoadHasBeenCalled];
    _disableTitleScrollerShadow = disableTitleScrollerShadow;
}
-(void)setDisableUIPageControl:(BOOL)disableUIPageControl{
    [self raiseErrorIfViewDidLoadHasBeenCalled];
    _disableUIPageControl = disableUIPageControl;
}
-(void)setHideStatusBarWhenScrolling:(bool)hideStatusBarWhenScrolling{
    if (hideStatusBarWhenScrolling){
        //check the info.plist required key has been set and throw an exception if not
        NSNumber *statusBarKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
        if (statusBarKey == nil || [statusBarKey isEqualToNumber:@1 ]){
            [NSException raise:@"TTScrollSlidingPagesController: Status Bar 'UIViewControllerBasedStatusBarAppearance' key missing from info.plist" format:@"The 'hideStarusBarWhenScrolling' property on the TTScrollSlidingPagesController is set to yes. This makes the page control (the page number dots) and the status bar share the same space at the top of the screen, and hide the status bar as the user changes pages. To do this, however you need to add the 'UIViewControllerBasedStatusBarAppearance' key to the info.plist and set it to a boolean of NO. See the instructions on github or the example project included with the control for help."];
        }
    }
    
    //otherwise, set the value
    _hideStatusBarWhenScrolling = hideStatusBarWhenScrolling;
    
    if (hideStatusBarWhenScrolling){
        //set the status bar style to light because the background it shares with the pagedots is black. You could do both of these in viewDidLoad, but doing it here just ensures that it still gets set if someone changed the property after viewDidLoad was called.
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }
}




@end
