//
//  WebSchoolLoginViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-24.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "WebSchoolLoginViewController.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "LoginManager.h"
#import "ConstantDefinition.h"

@interface WebSchoolLoginViewController () <LoginManagerProtocol>

@property (retain, nonatomic) LoginManager *loginManager;

@property (retain, nonatomic) IBOutlet UITextField *userNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UIButton *rightBarBtn;

@end

@implementation WebSchoolLoginViewController

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

- (void)didFailRequest
{
    NSLog(@"Login - request fail");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.rightBarBtn setEnabled:YES];
}

- (void)didFailLogin
{
    NSLog(@"Login - can't login");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.rightBarBtn setEnabled:YES];
}

- (void)didSucceedLogin
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //write to NSUserDefault
    [self.loginManager updateInUserDefault:self.userNameTextField.text password:self.passwordTextField.text];
  
#warning 待确定
    //是否把登录者的信息写入CoreData?
    
    //发送消息给LoginViewController，告诉它登录已完成
    [self.delegate didFinishLogin];
}


#pragma mark - action to dismiss keyboard

- (IBAction)userNameInputDone:(id)sender
{
    // to dismiss keyboard
}

- (IBAction)passwordInputDone:(id)sender
{
    // to dismiss keyboard
}

#pragma mark - action

- (IBAction)leftBarBtnPressed:(id)sender
{
    //back to LoginViewController
    [self.delegate didCancelLogin];
}

- (IBAction)rightBarBtnPressed:(id)sender
{
    //login
    NSString *username = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if ([username length] == 0 || [password length] == 0)
    {
        //show hud = 请输入正确的信息
    }
    else
    {
        //disable rightBarBtn
        [self.rightBarBtn setEnabled:NO];
        
        //show hud
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        //login
        
        [self.loginManager loginWithUsername:username password:password];
    }
}

#pragma mark - VC lifecycle

- (void)dealloc
{
    [_userNameTextField release];
    [_passwordTextField release];
    [_rightBarBtn release];
    [_loginManager release];
    [super dealloc];
}

@end
