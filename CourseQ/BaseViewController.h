//
//  BaseViewController.h
//  CourseQ
//
//  Created by Fee Val on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainPage.h"

enum SliderStatus {
    
    SliderStatusNormal = 0, // 默认为正常状态
    SliderStatusRight,  // 滑向右侧
    SliderStatusLeft, // 滑向左侧
};

typedef enum SliderStatus SliderStatus;

@interface BaseViewController : UIViewController
{
    CGPoint touchBeganPoint;
    BOOL homeViewIsOutOfStage;
}

@property (nonatomic,assign,getter = isLeftPressed) BOOL leftPressed;
@property (assign, nonatomic) BOOL isAnimating;
//@property (assign, nonatomic, getter = isAnimationCompleted) BOOL animationCompleted;
// 左移右移锁
@property (assign,nonatomic,getter = isRightSideLocked) BOOL rightSideLocked;
@property (assign,nonatomic,getter = isLeftSideLocked) BOOL leftSideLocked;
// 记录baseView的状态
@property (assign,nonatomic) SliderStatus currentSliderStatus;

- (IBAction)leftBarBtnTapped:(id)sender;
- (IBAction)rightBarBtnTapped:(id)sender;

// 滑动view的接口

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)restoreViewLocation:(UIGestureRecognizer *)ges;
- (void)moveToLeftSide;
- (void)moveToRightSide;
- (void)animateHomeViewToSide:(CGRect)newViewRect;


@end
