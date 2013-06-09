//
//  PreviewCell.m
//  CourseQ
//
//  Created by Fee Val on 13-6-8.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "PreviewCell.h"

@implementation PreviewCell

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
    
    [_causePicView release];
    [_pieceProgress release];
    [_cellBtnPlay release];
    [super dealloc];
}

@end
