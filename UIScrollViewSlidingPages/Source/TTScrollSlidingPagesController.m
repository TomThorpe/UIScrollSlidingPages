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
        self.titleScrollerBackgroundColour = [UIColor blackColor];
        self.titleScrollerTextColour = [UIColor whiteColor];
        self.disableTopScrollerShadow = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewDidLoadHasBeenCalled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate)name:UIDeviceOrientationDidChangeNotification object:nil];
    
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
    UIView *topScrollViewWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.titleScrollerHeight)];//make the view to put the scroll view inside.
    topScrollViewWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    topScrollViewWrapper.backgroundColor = self.titleScrollerBackgroundColour; //set the background colour (the whole point of having the wrapper)
    [topScrollViewWrapper addSubview:topScrollView];//put the top scroll view in the wrapper.
    
    [self.view addSubview:topScrollViewWrapper]; //put the wrapper in this view.
    
    
    //set up the bottom scroller (for the content to go in)
    bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.titleScrollerHeight, self.view.frame.size.width, self.view.frame.size.height-self.titleScrollerHeight)];
    bottomScrollView.pagingEnabled = YES;
    bottomScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    bottomScrollView.showsVerticalScrollIndicator = NO;
    bottomScrollView.showsHorizontalScrollIndicator = NO;
    bottomScrollView.directionalLockEnabled = YES;
    bottomScrollView.delegate = self; //move the top scroller proportionally as you drag the bottom.
    [self.view addSubview:bottomScrollView];
    
    //add the drop shadow on the top scroller (if enabled)
    if (!self.disableTopScrollerShadow){
        topScrollViewWrapper.layer.masksToBounds = NO;
        topScrollViewWrapper.layer.shadowOffset = CGSizeMake(0, 4);
        topScrollViewWrapper.layer.shadowRadius = 4;
        topScrollViewWrapper.layer.shadowOpacity = 0.3;
        [self.view bringSubviewToFront:topScrollViewWrapper];//bring view to sit on top so you can see the shadow!
    }
}


-(void)setDataSource:(id<TTSlidingPagesDataSource>)dataSource{
    _dataSource = dataSource;
    if (self.view != nil){
        [self reloadPages];
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
    
    //what page should the view start on? (change this if you want)
    int initialPage = 1;
    
    //loop through each page and add it to the scroller
    for (int i=0; i<numOfPages; i++){
        //get the page
        TTSlidingPage *page = [self.dataSource pageForSlidingPagesViewController:self atIndex:i];
        
        //top scroller (nav) add----
        UIView *topItem;
        if (page.headerImage != nil){
            topItem = (UIView *)page.headerImage;
        } else {
            UILabel *label = [[UILabel alloc] init];
            label.text = page.headerText;
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
        UIView *contentView = page.contentView;
        
        if (page.contentViewController != nil){
            [self addChildViewController:page.contentViewController];
            [page.contentViewController didMoveToParentViewController:self];
        }
        
        //put it in the right position, y is always 0, x is incremented with each item you add (it is a horizontal scroller).
        contentView.frame = CGRectMake(nextXPosition, 0, bottomScrollView.frame.size.width, bottomScrollView.frame.size.height);
        [bottomScrollView addSubview:contentView];
        nextXPosition = nextXPosition + contentView.frame.size.width;
        
        
    }
    
    //now set the content size of the scroller to be as wide as nextXPosition (we can know that nextXPosition is also the width of the scroller)
    topScrollView.contentSize = CGSizeMake(nextTopScrollerXPosition, topScrollView.frame.size.height);
    bottomScrollView.contentSize = CGSizeMake(nextXPosition, bottomScrollView.frame.size.height);
    
    //scroll to the initialpage
    topScrollView.contentOffset = CGPointMake(initialPage * topScrollView.frame.size.width, 0);
    bottomScrollView.contentOffset = CGPointMake(initialPage * bottomScrollView.frame.size.width, 0);
    
//    //set the number of dots on the page control, and set the initial selected dot
//    pageDots.numberOfPages = numberOfPages; //if you dont set the number of pages before you set the currentpage, it won't work. so make sure you do it it in the order here.
//    pageDots.currentPage = initialPage;
//    
//    
//    //fade in the page dots
//    [UIView animateWithDuration:1.5 animations:^{
//        pageDots.alpha = 1.0f;
//    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == bottomScrollView){
        //set the correct page on the pagedots
        //CGFloat pageWidth = scrollView.frame.size.width;
        //float fractionalPage = scrollView.contentOffset.x / pageWidth;
        //currentPage = lround(fractionalPage);
        //pageDots.currentPage = page;
        
        //translate the scroll to the top scroll
        //find out what percentage the bottom scroller is scroller through it's views (e.g if its total views are 100px wide, but it has scrolled to 3px, it is 0.03 or 3% through it's scroll area
        float percentageScrolled = scrollView.contentOffset.x / scrollView.contentSize.width;
        
        //multiply that by the content size of the top scroller. E.g if the top scroller is 50px wide, multiplied by 0.03 means we should scroll it to 1.5px, this'll get rounded in the computation, and the scroller will take care of it because paging is enabled.
        topScrollView.contentOffset = CGPointMake(topScrollView.contentSize.width * percentageScrolled, 0);
    }
}

-(void)didRotate{
    CGFloat pageWidth = bottomScrollView.frame.size.width;
    float fractionalPage = bottomScrollView.contentOffset.x / pageWidth;
    currentPageBeforeRotation = lround(fractionalPage);
}

-(void)viewWillLayoutSubviews{
    //this will get called when the screen rotates, at which point we need to fix the frames of all the subviews to be the new correct x position horizontally. The autolayout mask will automatically change the width for us.
    
    //reposition the subviews and set the new contentsize width
    CGRect frame;
    int nextXPosition = 0;
    for (UIView *view in bottomScrollView.subviews) {
        frame = view.frame;
        frame.size.width = bottomScrollView.frame.size.width;
        frame.origin.x = nextXPosition;
        nextXPosition += frame.size.width;
        view.frame = frame;
    }
    bottomScrollView.contentSize = CGSizeMake(nextXPosition, bottomScrollView.contentSize.height);

    //set it back to the same page as it was before (the contentoffset will be different now the widths are different)
    int contentOffsetWidth = currentPageBeforeRotation * bottomScrollView.frame.size.width;
    bottomScrollView.contentOffset = CGPointMake(contentOffsetWidth, 0);
    
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
-(void)setDisableTopScrollerShadow:(BOOL)disableTopScrollerShadow{
    [self raiseErrorIfViewDidLoadHasBeenCalled];
    _disableTopScrollerShadow = disableTopScrollerShadow;
}



@end
