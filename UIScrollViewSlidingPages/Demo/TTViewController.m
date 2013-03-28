//
//  TTViewController.m
//  UIScrollViewSlidingPages
//
//  Created by Thomas Thorpe on 27/03/2013.
//  Copyright (c) 2013 Thomas Thorpe. All rights reserved.
//

#import "TTViewController.h"
#import "TTScrollSlidingPagesController.h"
#import "TabOneViewController.h"
#import "TabTwoViewController.h"
#import "TTSlidingPage.h"

@interface TTViewController ()

@end

@implementation TTViewController

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
    
    //initial setup of the TTScrollSlidingPagesController. 
    TTScrollSlidingPagesController *slider = [[TTScrollSlidingPagesController alloc] init];

    
    //set properties to customiser the slider. Make sure you set these BEFORE you access any other properties on the slider, such as the view or the datasource. Best to do it immediately after calling the init method.
    //slider.titleScrollerHeight = 100;
    //slider.titleScrollerItemWidth=60;
    
    //set the datasource.
    slider.dataSource = self;
    
    //add the slider's view to this view as a subview, and add the viewcontroller to this viewcontrollers child collection (so that it gets retained and stays in memory! And gets all relevant events in the view controller lifecycle)
    slider.view.frame = self.view.frame;
    [self.view addSubview:slider.view];
    [self addChildViewController:slider];
    
        
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TTSlidingPagesDataSource methods
-(int)numberOfPagesForSlidingPagesViewController:(TTScrollSlidingPagesController *)source{
    return 2;
}
-(TTSlidingPage *)pageForSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index{
    if (index == 0){
        UIViewController *viewC1= [[TabOneViewController alloc] init];
        TTSlidingPage *page1 = [[TTSlidingPage alloc] initWithHeaderText:@"Page 1" andContentViewController:viewC1];
        return page1;
    } else {
        UIViewController *viewC2 = [[TabTwoViewController alloc] init];
        TTSlidingPage *page2 = [[TTSlidingPage alloc] initWithHeaderText:@"Page 2" andContentViewController:viewC2];
        return page2;
    }
}

@end
