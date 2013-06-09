//
//  BaseViewController.m
//  CourseQ
//
//  Created by Fee Val on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}

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
    if (self.currentSliderStatus != SliderStatusNormal) {
        
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
    CGFloat xOffSet = touchPoint.x - touchBeganPoint.x;
    
    // if (self.isRightSideLocked && touchPoint.x < touchBeganPoint.x) 先锁住右侧屏幕
    if (touchPoint.x < touchBeganPoint.x){
        
        xOffSet = 0;
    }
    
    if(self.isLeftSideLocked && touchPoint.x > touchBeganPoint.x){
        
        xOffSet = 0;
    }
    
    if (xOffSet >= kLeftMaxBounds) {
        
        xOffSet = kLeftMaxBounds;
    }
    
    if (xOffSet <= kRightMaxBounds) {
        // if (xOffSet <= kRightMaxBounds - kTriggerOffSet*2) { // 弹性
        xOffSet = kRightMaxBounds;
    }
    
    // WebSAppDelegate *appDelegate = (WebSAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (xOffSet < 0) {
        // [appDelegate makeRightViewVisible];
    }
    else if (xOffSet > 0) {
        //  [appDelegate makeLeftViewVisible];
    }
    
    self.view.frame = CGRectMake(xOffSet,
                                 self.view.frame.origin.y,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height);
}

// reset indicators when touch ended (Add by Ethan, 2011-11-27)
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.currentSliderStatus != SliderStatusNormal ) {
        
        [self restoreViewLocation:nil];
        return;
    }
    
    // animate to left side
    if (self.view.frame.origin.x < -kTriggerOffSet + kTriggerOffSet)
        [self moveToLeftSide];
    // animate to right side
    else if (self.view.frame.origin.x > kTriggerOffSet)
        [self moveToRightSide];
    // reset
    else{
        
        [self restoreViewLocation:nil];
    }
}

#pragma mark Other methods

// restore view location
- (void)restoreViewLocation:(UIGestureRecognizer *)ges{
    
    homeViewIsOutOfStage = NO;
    BaseViewController *weakNaviC = self;
    self.currentSliderStatus = SliderStatusNormal;
    // NSLog(@"%g,%g",self.view.frame.origin.x,self.view.frame.origin.y);
    [self.view setUserInteractionEnabled:YES];
    [UIView animateWithDuration:kMenuSlideAnimationDuration
                     animations:^{
                         weakNaviC.view.frame = CGRectMake(0,
                                                           weakNaviC.view.frame.origin.y,
                                                           weakNaviC.view.frame.size.width,
                                                           weakNaviC.view.frame.size.height);
                     }];
    
}

// move view to left side
- (void)moveToLeftSide {
    
    homeViewIsOutOfStage = YES;
    self.currentSliderStatus = SliderStatusLeft;
    // [self.view setUserInteractionEnabled:NO];
    [self animateHomeViewToSide:CGRectMake(kRightMaxBounds,
                                           self.view.frame.origin.y,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height)];
}

// move view to right side
- (void)moveToRightSide {
    
    self.leftPressed = YES;
    homeViewIsOutOfStage = YES;
    self.currentSliderStatus = SliderStatusRight;
    // [self.view setUserInteractionEnabled:NO];
    [self animateHomeViewToSide:CGRectMake(kLeftMaxBounds,
                                           self.view.frame.origin.y,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height)];
}

// animate home view to side rect
- (void)animateHomeViewToSide:(CGRect)newViewRect
{
    self.isAnimating = YES;
    [UIView animateWithDuration:kMenuSlideAnimationDuration
                     animations:^{
                         self.view.frame = newViewRect;
                     }
                     completion:^(BOOL finished){
                         
                         self.isAnimating = NO;
                     }];
}

#pragma mark - Handlers

// handle left bar btn
- (IBAction)leftBarBtnTapped:(id)sender {
    
    if (self.currentSliderStatus == SliderStatusNormal) {
        
        [self moveToRightSide];
    }
    else{
        
        [self restoreViewLocation:nil];
    }
}

// handle right bar btn
- (IBAction)rightBarBtnTapped:(id)sender {
    
    if (self.currentSliderStatus == SliderStatusNormal) {
        
        [self moveToLeftSide];
    }
    else{
        
        [self restoreViewLocation:nil];
    }
}

@end
