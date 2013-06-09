//
//  CourseListCell.m
//  WebSchool
//
//  Created by Fee Val on 13-1-14.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import "CourseListCell.h"

@implementation CourseListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)dealloc{
    
    [_thumbnailImageView release];
    [_titleLabel release];
    [_categoryLabel release];
    [_likeLabel release];
    [_readerLabel release];
    [_forwardLabel release];
    [_posterID release];
    [_posterPortrait release];
    [_postDate release];
    [super dealloc];
}
@end
