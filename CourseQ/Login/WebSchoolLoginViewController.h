//
//  WebSchoolLoginViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-24.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebSchoolLoginViewControllerProtocol <NSObject>
- (void)didFinishLogin;
- (void)didCancelLogin;
@end

@interface WebSchoolLoginViewController : UIViewController
@property (assign, nonatomic) id<WebSchoolLoginViewControllerProtocol> delegate;
@end
