//
//  CQReviewVC.h
//  CourseQ
//
//  Created by Fee Val on 13-5-27.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseBriefing.h"
#import "MicroCauseCell.h"

@protocol CQReviewVCProtocol <NSObject>
- (void)shouldBackToListVC:(UIViewController *)controller;
@end

@interface CQReviewVC : UIViewController
@property (assign, nonatomic) id <CQReviewVCProtocol> delegate;
// 下载课程
@property (copy, nonatomic) NSString *courseFileName;
@property (copy, nonatomic) NSString *pageCount;
@end
