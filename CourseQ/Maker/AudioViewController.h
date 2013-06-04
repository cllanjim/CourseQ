//
//  AudioViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-14.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AudioViewControllerProtocol <NSObject>
- (void)didCancelWithAudio;
- (void)didFinishWithAudio;
- (void)didFinishWithMaker;
@end

@interface AudioViewController : UIViewController

@property (assign, nonatomic) id<AudioViewControllerProtocol> delegate;

//MakerViewController通过以下属性传递存储路径和当前所在页数
@property (copy, nonatomic) NSString *audioSavePath;
@property (copy, nonatomic) NSString *imageSavePath;
@property (nonatomic) NSInteger pageNumber;

@end
