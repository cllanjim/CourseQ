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

@property (assign,nonatomic,getter = isRightSideLocked) BOOL rightSideLocked;
@property (assign,nonatomic,getter = isLeftSideLocked) BOOL leftSideLocked;

@property (assign, nonatomic) BOOL isAnimating;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
