//
//  MicroCauseCell.m
//  MicroCauseDemo
//
//  Created by Fee Val on 12-11-29.
//  Copyright (c) 2012年 Freebox. All rights reserved.
//

#import "MicroCauseCell.h"

@implementation MicroCauseCell

#pragma mark - Config Data

- (void)configurMicroCause:(Unit *)aPage{
    
    if (aPage.imagePath == nil) {
        
        // 空
    }
    else
    {
        NSData *imgData = [NSData dataWithContentsOfFile:aPage.imagePath];
        UIImage *img = [UIImage imageWithData:imgData];
        [self.causePicView setImage:img];
    }
    
}

#pragma mark - Defaults

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
