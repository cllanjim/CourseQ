//
//  LoginManager.h
//  CourseQ
//
//  Created by Jing on 13-5-29.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginManagerProtocol <NSObject>

- (void)didSucceedLogin;//登录成功
- (void)didFailLogin;//登录失败
- (void)didFailRequest;//request连接失败

@end

@interface LoginManager : NSObject

@property (assign, nonatomic) id <LoginManagerProtocol> delegate;

- (BOOL)isSavedUserInfo;
- (void)loginWithUsername:(NSString *)name password:(NSString *)password;
- (void)updateInUserDefault:(NSString *)username password:(NSString *)password;

@end
