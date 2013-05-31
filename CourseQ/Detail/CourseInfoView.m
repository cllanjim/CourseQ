//
//  CourseInfoView.m
//  WebSchool
//
//  Created by Fee Val on 13-5-2.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import "CourseInfoView.h"

@implementation CourseInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       //  [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    }
    return self;
}

- (void)dealloc {
    [_userPotrait release];
    [_posterLabel release];
    [_followBtn release];
    [_favorBtn release];
    [super dealloc];
}
@end
