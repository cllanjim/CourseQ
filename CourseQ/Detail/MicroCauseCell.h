//
//  MicroCauseCell.h
//  MicroCauseDemo
//
//  Created by Fee Val on 12-11-29.
//  Copyright (c) 2012年 Freebox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Unit.h"

@interface MicroCauseCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *causePicView;
@property (retain, nonatomic) IBOutlet UIButton *cellBtnPlay;
@property (retain, nonatomic) IBOutlet UIProgressView *pieceProgress;

// ========@            @========

- (void)configurMicroCause:(Unit *)aPage;

@end
