//
//  TTSliddingPageDelegate.h
//  UIScrollSlidingPages
//
//  Created by John Doran on 06/12/2013.
//  Copyright (c) 2013 Thomas Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TTSliddingPageDelegate <NSObject>

-(void)didScrollToViewAtIndex:(NSUInteger)index;

@end
