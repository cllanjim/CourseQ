//
//  LoginViewControllerDelegate.h
//  CourseQ
//
//  Created by Jing on 13-5-24.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginViewControllerDelegate <NSObject>

- (void)didFinishLogin;

- (void)didCancelLogin;

@end
