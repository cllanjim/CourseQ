//
//  BaseViewController.m
//  CourseQ
//
//  Created by Fee Val on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController () {
    CGPoint touchBeganPoint;
}

@end

@implementation BaseViewController

#pragma mark Override touch methods

// Check touch position in this method (Add by Ethan, 2011-11-27)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    touchBeganPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
}

// Scale or move select view when touch moved (Add by Ethan, 2011-11-27)
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    CGFloat xOffSet = touchPoint.x - touchBeganPoint.x;
    
    //只允许右移
    if (touchPoint.x < touchBeganPoint.x)
    {
        xOffSet = 0;
    }
    
    if(self.rightSideLocked)
    {
        xOffSet = 0;
    }
    
    if (xOffSet >= kLeftMaxBounds) {
        xOffSet = kLeftMaxBounds;
    }
    
    if (xOffSet <= kRightMaxBounds) {
        // if (xOffSet <= kRightMaxBounds - kTriggerOffSet*2) { // 弹性
        xOffSet = kRightMaxBounds;
    }
    
    self.view.frame = CGRectMake(xOffSet,
                                 self.view.frame.origin.y,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height);
}

// reset indicators when touch ended (Add by Ethan, 2011-11-27)
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // animate to left side
    if (self.view.frame.origin.x < -kTriggerOffSet + kTriggerOffSet)
        [self moveToLeftSide];
    // animate to right side
    else if (self.view.frame.origin.x > kTriggerOffSet)
        [self moveToRightSide];
    // reset
    else{
        
        [self restoreViewLocation];
    }
    
    
}

#pragma mark Other methods

// restore view location
- (void)restoreViewLocation
{
    [UIView animateWithDuration:kMenuSlideAnimationDuration animations:^{
        self.view.frame = CGRectMake(0,
                                     self.view.frame.origin.y,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        UIControl *overView = (UIControl *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:10086];
        [overView removeFromSuperview];
    }];
}

// move view to left side
- (void)moveToLeftSide
{
    [self animateHomeViewToSide:CGRectMake(kRightMaxBounds,
                                           self.view.frame.origin.y,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height)];
}

// move view to right side
- (void)moveToRightSide
{
    [self animateHomeViewToSide:CGRectMake(kLeftMaxBounds,
                                           self.view.frame.origin.y,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height)];
}

// animate home view to side rect
- (void)animateHomeViewToSide:(CGRect)newViewRect
{
    self.isAnimating = YES;
    
    [UIView animateWithDuration:kMenuSlideAnimationDuration animations:^{
        self.view.frame = newViewRect;
        
    } completion:^(BOOL finished) {
        UIControl *overView = [[UIControl alloc] init];
        overView.tag = 10086;
        overView.frame = self.view.frame;
        [overView addTarget:self action:@selector(restoreViewLocation) forControlEvents:UIControlEventTouchDown];
        [[[UIApplication sharedApplication] keyWindow] addSubview:overView];
        [overView release];
        self.isAnimating = NO;
    }];
}

#pragma mark - Handlers

// handle left bar btn
- (IBAction)leftBarBtnTapped:(id)sender {
    [self moveToRightSide];
}

// handle right bar btn
- (IBAction)rightBarBtnTapped:(id)sender {

    [self moveToLeftSide];
}

@end
