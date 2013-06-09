//
//  SettingViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-14.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol SettingViewControllerProtocol <NSObject>
- (void)didFinishLogout;
@end

@interface SettingViewController : BaseViewController
@property (assign, nonatomic) id <SettingViewControllerProtocol> delegate;
@end
