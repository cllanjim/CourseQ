//
//  CourseInfoView.h
//  WebSchool
//
//  Created by Fee Val on 13-5-2.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseInfoView : UIView

@property (retain, nonatomic) IBOutlet UIImageView *userPotrait;
@property (retain, nonatomic) IBOutlet UILabel *posterLabel;

// 按钮
@property (retain, nonatomic) IBOutlet UIButton *followBtn;
@property (retain, nonatomic) IBOutlet UIButton *favorBtn;


@end
