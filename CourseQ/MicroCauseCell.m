//
//  MicroCauseCell.m
//  MicroCauseDemo
//
//  Created by Fee Val on 12-11-29.
//  Copyright (c) 2012年 Freebox. All rights reserved.
//

#import "MicroCauseCell.h"

@implementation MicroCauseCell


#pragma mark - defualts
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
    
    [super dealloc];
}
@end
