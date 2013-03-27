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
    // Do any additional setup after loading the view from its nib.
    
    
    slider = [[TTScrollSlidingPagesController alloc] init];
    slider.view.frame = self.view.frame;
    slider.dataSource = self;
    
    [self.view addSubview:slider.view];
    
        
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
