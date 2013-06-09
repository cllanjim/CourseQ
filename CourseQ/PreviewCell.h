//
//  PreviewCell.h
//  CourseQ
//
//  Created by Fee Val on 13-6-8.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Unit.h"

@interface PreviewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *causePicView;
@property (retain, nonatomic) IBOutlet UIButton *cellBtnPlay;
@property (retain, nonatomic) IBOutlet UIProgressView *pieceProgress;

// ========@            @========

- (void)configurMicroCause:(Unit *)aPage;

@end
