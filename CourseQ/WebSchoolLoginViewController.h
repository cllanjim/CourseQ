//
//  WebSchoolLoginViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-24.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewControllerDelegate.h"

@interface WebSchoolLoginViewController : UIViewController

@property (assign, nonatomic) id<LoginViewControllerDelegate> delegate;

@end
