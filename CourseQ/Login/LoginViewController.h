//
//  LoginViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerProtocol <NSObject>
- (void)didFinishLogin:(UIViewController *)controller;
@end

@interface LoginViewController : UIViewController
@property (assign, nonatomic) id <LoginViewControllerProtocol> delegate;
@end
