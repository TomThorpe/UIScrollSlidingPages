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

@interface TTScrollSlidingPagesController ()

@end

@implementation TTScrollSlidingPagesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //change this to adjust height of top nav titles (untested)
    int topScrollerHeight = 50;
    int topScrollerFrameWidth = 120;
    
    //set up the top scroller (for the nav titles to go in) - it is one frame wide, but has clipToBounds turned off to enable you to see the next and previous items in the scroller
    topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, topScrollerFrameWidth, topScrollerHeight)];
    topScrollView.center = CGPointMake(self.view.center.x, topScrollView.center.y); //center it horizontally
    topScrollView.pagingEnabled = YES;
    topScrollView.clipsToBounds = NO;
    topScrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    topScrollView.showsVerticalScrollIndicator = NO;
    topScrollView.showsHorizontalScrollIndicator = NO;
    topScrollView.directionalLockEnabled = YES;
    topScrollView.userInteractionEnabled = NO; //for now I won't let the user drag the top scroller, might allow it in the future.
    [self.view addSubview:topScrollView];

    
    //set up the bottom scroller (for the content to go in)
    bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topScrollerHeight, self.view.frame.size.width, self.view.frame.size.height-topScrollerHeight)];
    bottomScrollView.pagingEnabled = YES;
    bottomScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    bottomScrollView.showsVerticalScrollIndicator = NO;
    bottomScrollView.showsHorizontalScrollIndicator = NO;
    bottomScrollView.directionalLockEnabled = YES;
    bottomScrollView.delegate = self; //move the top scroller proportionally as you drag the bottom.
    [self.view addSubview:bottomScrollView];
    
    //remove this
    topScrollView.backgroundColor = [UIColor redColor];

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
    
    if (viewControllers == nil){
        viewControllers = [[NSMutableArray alloc] init];
    }
    [viewControllers removeAllObjects];
    
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
            [viewControllers addObject:page.contentViewController];
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
        ////set the correct page on the pagedots
        //CGFloat pageWidth = scrollView.frame.size.width;
        //float fractionalPage = scrollView.contentOffset.x / pageWidth;
        //NSInteger page = lround(fractionalPage);
        //pageDots.currentPage = page;
        
        //translate the scroll to the top scroll
        //find out what percentage the bottom scroller is scroller through it's views (e.g if its total views are 100px wide, but it has scrolled to 3px, it is 0.03 or 3% through it's scroll area
        float percentageScrolled = scrollView.contentOffset.x / scrollView.contentSize.width;
        
        //multiply that by the content size of the top scroller. E.g if the top scroller is 50px wide, multiplied by 0.03 means we should scroll it to 1.5px, this'll get rounded in the computation, and the scroller will take care of it because paging is enabled.
        topScrollView.contentOffset = CGPointMake(topScrollView.contentSize.width * percentageScrolled, 0);
    }
}

@end
