//
//  CourseListCell.h
//  WebSchool
//
//  Created by Fee Val on 13-1-14.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseListCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *categoryLabel;
@property (retain, nonatomic) IBOutlet UILabel *likeLabel;
@property (retain, nonatomic) IBOutlet UILabel *readerLabel;
@property (retain, nonatomic) IBOutlet UILabel *forwardLabel;

@property (retain, nonatomic) IBOutlet UILabel *posterID;
@property (retain, nonatomic) IBOutlet UIImageView *posterPortrait;
@property (retain, nonatomic) IBOutlet UILabel *postDate;

@end
