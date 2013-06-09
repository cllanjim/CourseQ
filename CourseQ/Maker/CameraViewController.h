//
//  CameraViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-16.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraViewControllerProtocol <NSObject>
- (void)didMoveToAlbumVC;
- (void)didBackToListVC;
- (void)didFinishWithCamera;
@end

@interface CameraViewController : UIViewController
@property (assign, nonatomic) id<CameraViewControllerProtocol> delegate;
@property (copy, nonatomic) NSString *imageSavePath;
@end
