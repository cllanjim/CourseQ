//
//  BaseViewController.h
//  CourseQ
//
//  Created by Fee Val on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainPage.h"

@interface BaseViewController : UIViewController
{
    CGPoint touchBeganPoint;
    BOOL homeViewIsOutOfStage;
}

@property (nonatomic,assign,getter = isLeftPressed) BOOL leftPressed;

@property (assign,nonatomic,getter = isRightSideLocked) BOOL rightSideLocked;
@property (assign,nonatomic,getter = isLeftSideLocked) BOOL leftSideLocked;

@property (assign, nonatomic) BOOL animationCompleted;

- (IBAction)leftBarBtnTapped:(id)sender;
- (IBAction)rightBarBtnTapped:(id)sender;

// 滑动view的接口

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)restoreViewLocation;
- (void)moveToLeftSide;
- (void)moveToRightSide;
- (void)animateHomeViewToSide:(CGRect)newViewRect;


@end
