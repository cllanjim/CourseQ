//
//  UploadViewController.h
//  CourseQ
//
//  Created by Jing on 13-6-8.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UploadViewControllerProtocol <NSObject>

- (void)didCancelWithUpload;
- (void)didFinishWithUpload;

@end

@interface UploadViewController : UIViewController
@property (assign, nonatomic) id<UploadViewControllerProtocol> delegate;
@end
