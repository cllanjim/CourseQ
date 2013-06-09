//
//  CourseBriefing.m
//  CourseQ
//
//  Created by Fee Val on 13-5-27.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "CourseBriefing.h"

@implementation CourseBriefing

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    
    [_topCoverView release];
    [_coverIMG release];
    [_titleLabel release];
    [_bellowMenuView release];
    [_userPortrait release];
    [_favorLabel release];
    [_hitsLabel release];
    [_forwardLabel release];
    [_posterLabel release];
    [_posterDateLabel release];
    [super dealloc];
}
@end
