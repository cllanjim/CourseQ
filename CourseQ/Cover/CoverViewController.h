//
//  CoverViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-29.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoverViewControllerProtocol <NSObject>
- (void)didSucceedAutomaticLogin:(UIViewController *)controller;
- (void)didFailAutomaticLogin:(UIViewController *)controller;
- (void)didFailToServer:(UIViewController *)controller;
@end

@interface CoverViewController : UIViewController
@property (assign, nonatomic) id <CoverViewControllerProtocol> delegate;
@end
