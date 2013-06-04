//
//  PhotoMaskView.h
//  CourseQ
//
//  Created by Jing on 13-5-15.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoMaskView : UIView

@property (nonatomic) CGRect imageDisplayRect;
@property (nonatomic) CGFloat imageDisplayBorderWidth;
@property (retain, nonatomic) UIColor *imageDisplayBorderColor;
@property (nonatomic) CGColorRef backgroundColor;

@end
