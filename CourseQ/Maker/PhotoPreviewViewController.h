//
//  PhotoPreviewViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-15.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoPreviewViewControllerDelegate <NSObject>
- (void)didBackToListVC;
- (void)didFinishWithPhotoPreview:(BOOL)photoAccepted;
@end

@interface PhotoPreviewViewController : UIViewController
@property (retain, nonatomic) UIImage *capturedImage;
@property (assign, nonatomic) id<PhotoPreviewViewControllerDelegate> delegate;
@end
