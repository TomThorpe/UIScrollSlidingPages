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

@interface TTScrollSlidingPagesController : UIViewController<UIScrollViewDelegate>{
    int currentPageBeforeRotation;
    bool viewDidLoadHasBeenCalled;
    UIScrollView *bottomScrollView, *topScrollView;
}

-(void)reloadPages;
-(void)didRotate;


@property (nonatomic, strong) id<TTSlidingPagesDataSource> dataSource;

/**  @property titleScrollerHeight
 *   @brief The height of the top scroller
 *   The height of the top navigation scroller (the one with the header texts or images in). If not set, this will default to 50px.  **/
@property (nonatomic) int titleScrollerHeight;

/**  @property titleScrollerItemWidth
 *   @brief The width of each item in the top scroller
 *   The width of each individual item in the top scroller. The wider it is, the less of the previous and next items you'll see, the narrower it is the more of the previous and next items you'll see but the more likely you won't have enough width for your title! Default if not set is 120px  **/
@property (nonatomic) int titleScrollerItemWidth;

/**  @property titleScrollerBackgroundColour
 *   @brief The background colour of the top scroller
 *   The background colour of the top scroller. If you want it to be a texture image, you can use [UIColor colorWithPatternImage]. If not set, the default will be black. **/
@property (nonatomic, strong) UIColor *titleScrollerBackgroundColour;

/**  @property titleScrollerBackgroundColour
 *   @brief The colour of the text in the top scroller
 *   The colour of the text in the top scroller. If not set, the default will be white. **/
@property (nonatomic, strong) UIColor *titleScrollerTextColour;




@end
