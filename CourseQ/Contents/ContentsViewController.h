//
//  ContentsViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContentsViewControllerProtocol <NSObject>
- (void)didPressListVCBtn;
- (void)didPressProfileVCBtn;
- (void)didPressSettingVCBtn;
@end

@interface ContentsViewController : UIViewController
@property (assign, nonatomic) id <ContentsViewControllerProtocol> delegate;
@end
