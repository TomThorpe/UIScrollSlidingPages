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

@interface TTScrollSlidingPagesController ()

@end

@implementation TTScrollSlidingPagesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        viewDidLoadHasBeenCalled = NO;
        //set defaults
        self.titleScrollerHeight = 50;
        self.titleScrollerItemWidth = 120;
        
        UIImage *backgroundImage = [UIImage imageNamed:@"diagmonds.png"];
        if (backgroundImage != nil){
            self.titleScrollerBackgroundColour = [UIColor colorWithPatternImage:backgroundImage];
        } else {
            self.titleScrollerBackgroundColour = [UIColor blackColor];
        }
        
        self.titleScrollerTextColour = [UIColor whiteColor];
        self.disableTitleScrollerShadow = NO;
        self.disableUIPageControl = NO;
        self.initialPageNumber = 0;
        self.pagingEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewDidLoadHasBeenCalled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate)name:UIDeviceOrientationDidChangeNotification object:nil];
    
    int nextYPosition = 0;
    if (!self.disableUIPageControl){
        //create and add the UIPageControl
        int pageViewHeight = 15;
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, nextYPosition, self.view.frame.size.width, pageViewHeight)];
        pageControl.backgroundColor = [UIColor blackColor];
        pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:pageControl];
         nextYPosition += pageViewHeight;
    }
    
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
    topScrollView.userInteractionEnabled = NO; //for now I won't let the user drag the top scroller, might allow it in the future.
    UIView *topScrollViewWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, nextYPosition, self.view.frame.size.width, self.titleScrollerHeight)];//make the view to put the scroll view inside.
    topScrollViewWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    topScrollViewWrapper.backgroundColor = self.titleScrollerBackgroundColour; //set the background colour (the whole point of having the wrapper)
    [topScrollViewWrapper addSubview:topScrollView];//put the top scroll view in the wrapper.
    [self.view addSubview:topScrollViewWrapper]; //put the wrapper in this view.
    nextYPosition += self.titleScrollerHeight;
    
    //set up the bottom scroller (for the content to go in)
    bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, nextYPosition, self.view.frame.size.width, self.view.frame.size.height-nextYPosition)];
    bottomScrollView.pagingEnabled = self.pagingEnabled;
    bottomScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    bottomScrollView.showsVerticalScrollIndicator = NO;
    bottomScrollView.showsHorizontalScrollIndicator = NO;
    bottomScrollView.directionalLockEnabled = YES;
    bottomScrollView.delegate = self; //move the top scroller proportionally as you drag the bottom.
    [self.view addSubview:bottomScrollView];
    
    //add the drop shadow on the top scroller (if enabled)
    if (!self.disableTitleScrollerShadow){
        topScrollViewWrapper.layer.masksToBounds = NO;
        topScrollViewWrapper.layer.shadowOffset = CGSizeMake(0, 4);
        topScrollViewWrapper.layer.shadowRadius = 4;
        topScrollViewWrapper.layer.shadowOpacity = 0.3;
        [self.view bringSubviewToFront:topScrollViewWrapper];//bring view to sit on top so you can see the shadow!
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        if (title.headerImage != nil){
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
            label.backgroundColor = [UIColor clearColor];
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
        UIView *contentView = page.contentView;
        
        //put it in the right position, y is always 0, x is incremented with each item you add (it is a horizontal scroller).
        contentView.frame = CGRectMake(nextXPosition, 0, pageWidth, bottomScrollView.frame.size.height);
        [bottomScrollView addSubview:contentView];
        nextXPosition = nextXPosition + contentView.frame.size.width;
        
        if (page.contentViewController != nil){
            [self addChildViewController:page.contentViewController];
            [page.contentViewController didMoveToParentViewController:self];
        }
        
    }
    
    //now set the content size of the scroller to be as wide as nextXPosition (we can know that nextXPosition is also the width of the scroller)
    topScrollView.contentSize = CGSizeMake(nextTopScrollerXPosition, topScrollView.frame.size.height);
    bottomScrollView.contentSize = CGSizeMake(nextXPosition, bottomScrollView.frame.size.height);
    
    int initialPage = self.initialPageNumber;
    
    //set the number of dots on the page control, and set the initial selected dot
    pageControl.numberOfPages = numOfPages;
    pageControl.currentPage = initialPage;
    
    
    //fade in the page dots
    if (pageControl.alpha != 1.0){
        [UIView animateWithDuration:1.5 animations:^{
            pageControl.alpha = 1.0f;
        }];
    }
    
    //scroll to the initialpage
    [self scrollToPage:initialPage animated:NO];
}

-(int)getCurrentDisplayedPage{
    //cycle through all the subviews until you get to a position that matches the offset then that's what page youre on (each view can be a different width)
    int page = 0;
    int xPosition = 0;
    for (UIView *view in bottomScrollView.subviews)
    {
        xPosition += view.frame.size.width;
        if (bottomScrollView.contentOffset.x < xPosition){
            break;
        }
        page++;
    }
    
    return page;
}

-(int)getXPositionOfPage:(int)page{
    int xPosition = 0;
    int curPage = 0;
    for (UIView *subview in bottomScrollView.subviews)
    {
        if (curPage >= page){
            break;
        }
        curPage++;
        xPosition += subview.frame.size.width; //each view could in theory have a different width
    }
    
    return xPosition;
}


-(void)didRotate{
    currentPageBeforeRotation = [self getCurrentDisplayedPage];
}

-(void)scrollToPage:(int)page animated:(BOOL)animated{
    currentPageBeforeRotation = page;
    [topScrollView setContentOffset: CGPointMake(page * topScrollView.frame.size.width, 0) animated:animated];
    [bottomScrollView setContentOffset: CGPointMake([self getXPositionOfPage:page],0) animated:animated];
}

-(void)viewDidLayoutSubviews{
    //this will get called when the screen rotates, at which point we need to fix the frames of all the subviews to be the new correct x position horizontally. The autolayout mask will automatically change the width for us.
    
    //reposition the subviews and set the new contentsize width
    CGRect frame;
    int nextXPosition = 0;
    for (UIView *view in bottomScrollView.subviews) {
        frame = view.frame;
        frame.origin.x = nextXPosition;
        nextXPosition += frame.size.width;
        view.frame = frame;
    }
    bottomScrollView.contentSize = CGSizeMake(nextXPosition, bottomScrollView.contentSize.height);
    
    //set it back to the same page as it was before (the contentoffset will be different now the widths are different)
    int contentOffsetWidth = [self getXPositionOfPage:currentPageBeforeRotation];
    bottomScrollView.contentOffset = CGPointMake(contentOffsetWidth, 0);
    
}

#pragma mark UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == bottomScrollView){
        int currentPage = [self getCurrentDisplayedPage];
        
        //set the correct page on the pagedots
        pageControl.currentPage = currentPage;
                
        //translate the scroll to the top scroll
        //get the x position of the page in the top scroller
        int topXPosition = self.titleScrollerItemWidth * currentPage;
        
        //work out the percentage past this page the view currently is, by getting the xPosition of the next page and seeing how close it is
        float currentPageStartXPosition = [self getXPositionOfPage:currentPage]; //subtract the current page's start x position from both the current offset and next page's start position, to mean that we're on a base level. So for example if we're on page 1 so that the currentPageStartXPosition is 320, and the current offset is 330, the next page xPosition is 640, then 330-320 - 10, and 640-320 - 320. So we're 10 pixels into 320, so roughly 3%.
        float nextPagesXPosition = [self getXPositionOfPage:currentPage+1];
        float percentageTowardsNextPage = (scrollView.contentOffset.x-currentPageStartXPosition) / (nextPagesXPosition-currentPageStartXPosition);
        //multiply the percentage towards the next page that you are, by the width of each topScroller item, and add it to the topXPosition
        
        float addToTopXPosition = percentageTowardsNextPage * self.titleScrollerItemWidth;
        topXPosition = topXPosition + roundf(addToTopXPosition);
        
        topScrollView.contentOffset = CGPointMake(topXPosition, 0);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    /*Just do a quick check, that if the paging enabled property is YES (paging is enabled), the user should not define widthForPageOnSlidingPagesViewController on the datasource delegate because scrollviews do not cope well with paging being enabled for scrollviews where each subview is not full width! */
    if (self.pagingEnabled == YES && [self.dataSource respondsToSelector:@selector(widthForPageOnSlidingPagesViewController:atIndex:)]){
        NSLog(@"Warning: TTScrollSlidingPagesController. You have paging enabled in the TTScrollSlidingPagesController (pagingEnabled is either not set, or specifically set to YES), but you have also implemented widthForPageOnSlidingPagesViewController:atIndex:. ScrollViews do not cope well with paging being disabled when items have custom widths. You may get weird behaviour with your paging, in which case you should either disable paging (set pagingEnabled to NO) and keep widthForPageOnSlidingPagesViewController:atIndex: implented, or not implement widthForPageOnSlidingPagesViewController:atIndex: in your datasource for the TTScrollSlidingPagesController instance.");
    }
}

#pragma mark property setters - for when need to do fancy things as well as set the value

-(void)setDataSource:(id<TTSlidingPagesDataSource>)dataSource{
    _dataSource = dataSource;
    if (self.view != nil){
        [self reloadPages];
    }
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
//-initialPageNumber can be set whenever so it's included here.



@end
