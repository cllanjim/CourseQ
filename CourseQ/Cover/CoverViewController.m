//
//  CoverViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-29.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "CoverViewController.h"
#import "LoginManager.h"

#define WAIT_TIME_INTERVAL 1.0

@interface CoverViewController () <LoginManagerProtocol>
@property (retain, nonatomic) LoginManager *loginManager;
@property (assign, nonatomic) BOOL isLoginSuccessfully;
@property (assign, nonatomic) NSTimer *timer;
@end

@implementation CoverViewController

#pragma mark - LoginManager & its delegate

- (LoginManager *)loginManager
{
    if (_loginManager == nil) {
        _loginManager = [[[LoginManager alloc] init] autorelease];
        [_loginManager setDelegate:self];
        [_loginManager retain];
    }
    
    return _loginManager;
}

- (void)didSucceedLogin
{
    self.isLoginSuccessfully = YES;
}

- (void)didFailLogin
{
    self.isLoginSuccessfully = NO;
}

- (void)didFailRequest
{
    self.isLoginSuccessfully = NO;
}

#pragma mark - action

- (void)prepareForNextVC
{
    [self.timer invalidate];
    
    if (self.isLoginSuccessfully) {
        [self.delegate didSucceedAutomaticLogin:self];
    }else {
        [self.delegate didFailAutomaticLogin:self];
    }
}

#pragma mark - VC lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:WAIT_TIME_INTERVAL target:self selector:@selector(prepareForNextVC) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
