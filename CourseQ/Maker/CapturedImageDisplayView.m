//
//  CapturedImageDisplayView.m
//  CourseQ
//
//  Created by Jing on 13-5-15.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "CapturedImageDisplayView.h"

@implementation CapturedImageDisplayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCapturedImage:(UIImage *)capturedImage {
    _capturedImage = capturedImage;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    
    
    if (self.capturedImage) {
        [self.capturedImage drawInRect:self.bounds];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 4.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextStrokeRect(context, self.bounds);
    
}


@end
