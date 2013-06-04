//
//  ListViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

#warning 每次进入分类，就要显示分类列表？

@protocol ListViewControllerDelegate <NSObject>

- (void)didSelectRowWithCourseFileName:(NSString *)name pageCount:(NSString *)count VC:(UIViewController *)controller;
- (void)shouldMoveToMakerVC;

@end

@interface ListViewController : BaseViewController

@property (assign, nonatomic) id<ListViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL refresh;
@end
