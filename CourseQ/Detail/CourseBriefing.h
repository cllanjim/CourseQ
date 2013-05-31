//
//  CourseBriefing.h
//  CourseQ
//
//  Created by Fee Val on 13-5-27.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseBriefing : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *topCoverView;
@property (retain, nonatomic) IBOutlet UIImageView *coverIMG;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (retain, nonatomic) IBOutlet UIView *bellowMenuView;
@property (retain, nonatomic) IBOutlet UIImageView *userPortrait;
@property (retain, nonatomic) IBOutlet UILabel *favorLabel;
@property (retain, nonatomic) IBOutlet UILabel *hitsLabel;
@property (retain, nonatomic) IBOutlet UILabel *forwardLabel;
@property (retain, nonatomic) IBOutlet UILabel *posterLabel;
@property (retain, nonatomic) IBOutlet UILabel *posterDateLabel;

@end
