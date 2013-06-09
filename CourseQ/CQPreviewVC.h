//
//  CQPreviewVC.h
//  CourseQ
//
//  Created by Fee Val on 13-6-3.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CQPreviewVCProtocol <NSObject>

- (void)shouldUpload;
- (void)didCancelWithPreview;

@end

@interface CQPreviewVC : UIViewController

@property (retain, nonatomic) id<CQPreviewVCProtocol> delegate;

@end
