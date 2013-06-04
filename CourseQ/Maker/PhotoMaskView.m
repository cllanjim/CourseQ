//
//  PhotoMaskView.m
//  CourseQ
//
//  Created by Jing on 13-5-15.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "PhotoMaskView.h"

@interface PhotoMaskView (){
    CGColorSpaceRef colorSpace;
}

@end

@implementation PhotoMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _imageDisplayBorderColor = [UIColor blackColor];
    _imageDisplayBorderWidth = 4.0;
    _imageDisplayRect = CGRectMake(10.0, 62.0, 300.0, 300.0);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    _backgroundColor = CGColorCreate(colorSpace, (CGFloat[]){0, 0, 0, 0.5});
}

- (void)drawRect:(CGRect)rect {
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRetain(context);
    
    //CGContextSaveGState(context);
    CGContextClearRect(context, self.imageDisplayRect);
    
    //CGContextRestoreGState(context);
    
    //border
    CGContextSetStrokeColorWithColor(context, [self.imageDisplayBorderColor CGColor]);
    CGContextSetLineWidth(context, self.imageDisplayBorderWidth);
    CGContextStrokeRect(context, self.imageDisplayRect);
    
    
    //background
    CGContextBeginPath(context);
    CGContextAddRect(context, self.imageDisplayRect);
    CGContextAddRect(context, self.bounds);
    
    CGContextSetFillColorWithColor(context, self.backgroundColor);
    CGContextEOFillPath(context);
    
    CGContextRelease(context);
     
}

- (void)dealloc {
    
    self.imageDisplayBorderColor = nil;
    self.backgroundColor = nil;
    colorSpace = nil;
    
    [_imageDisplayBorderColor release];
    CGColorSpaceRelease(colorSpace);
    CGColorRelease(_backgroundColor);
    
    [super dealloc];
}


@end
