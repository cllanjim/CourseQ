//
//  SettingViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-14.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "SettingViewController.h"

@implementation SettingViewController

- (IBAction)logoutBtnPressed:(id)sender {
    [self.delegate didFinishLogout];
}

@end
