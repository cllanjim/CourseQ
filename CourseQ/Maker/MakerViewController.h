//
//  MakerViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MakerViewControllerProtocol <NSObject>

- (void)didCancelWithMaker:(UIViewController *)controller;

@end

@interface MakerViewController : UIViewController

@property (assign, nonatomic) id <MakerViewControllerProtocol> delegate;
@end
