//
//  LoginManager.m
//  CourseQ
//
//  Created by Jing on 13-5-29.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "LoginManager.h"
#import "ASIHTTPRequest.h"
#import "DataParser.h"
#import "ConstantDefinition.h"

@interface LoginManager () <ASIHTTPRequestDelegate>
@end

@implementation LoginManager

- (void)loginWithUsername:(NSString *)name password:(NSString *)password
{
    if ([name length] && [password length]) {
        
        //url
        NSString *input = [NSString stringWithFormat:@"%@@-%@", name, password];
        NSString *inputURLPath = [NSString stringWithFormat:@"%@%@", _WebAdressOfFreeboxWS_LOGIN_2_0, input];
        NSURL *url = [NSURL URLWithString:inputURLPath];
        
        //request
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [request startSynchronous];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self.delegate didFailRequest];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@", [request responseString]);
    if ([[request.responseString substringToIndex:5] isEqualToString:@"LOGIN"]) {
        if ([DataParser loginApplication:request.responseString]) {
            [self.delegate didSucceedLogin];
        }else {
            [self.delegate didFailLogin];
        }
        
    }else {
        [self.delegate didFailRequest];
    }
}

- (void)updateInUserDefault:(NSString *)username password:(NSString *)password
{
    NSURL *url = [NSURL URLWithString:_WebAdressOfFreeboxWS_PROFILE_2_0];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    
    NSArray *userMemberIDArr = [[DataParser commonParser:[request responseString]]objectAtIndex:2];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:YES forKey:USER_ISSAVED];
    [ud setValue:userMemberIDArr[0] forKey:USER_ID];
    [ud setValue:username forKey:USER_NICKNAME];
    [ud setValue:password forKey:USER_PASSWORD];
    [ud synchronize];
}

- (BOOL)isSavedUserInfo
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:USER_ISSAVED];
}

@end
