//
//  FilePathHelper.m
//  WebSchool
//
//  Created by Fee Val on 13-2-20.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import "FilePathHelper.h"

@interface FilePathHelper()

@property (assign, nonatomic) NSInteger page;

@property (copy, nonatomic) NSString *saveName;
@property (copy, nonatomic) NSString *savePath;

@end

@implementation FilePathHelper

#pragma mark - page

- (void)setCurrentPage:(NSInteger)page {
    _page = page;
}

- (NSInteger)currentPage {
    return _page;
}

#pragma mark - path

- (NSString *)imagePath {
    
    NSString *imageName = [NSString stringWithFormat:@"_image%02d.jpg", self.page];
    NSString *imagePath = [self.savePath stringByAppendingString:imageName];
    
    return imagePath;
}

- (NSString *)thumbnailPath {
    
    NSString *thumbnailName = @"_thumb.jpg";
    NSString *thumbnailPath = [self.savePath stringByAppendingString:thumbnailName];
    
    return thumbnailPath;
}

- (NSString *)audioPath {
    
    NSString *audioName = [NSString stringWithFormat:@"_sound%02d.aac", self.page];
    NSString *audioPath = [self.savePath stringByAppendingString:audioName];
    
    return audioPath;
}

#pragma mark - others

- (NSString *)savePath {

    NSString *userPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    userPath = [userPath stringByAppendingPathComponent:@"microCourses"];
    
    NSLog(@"userP:%@", userPath);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:userPath]) {
        [fm createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [fm changeCurrentDirectoryPath:userPath];
    
    if (![fm fileExistsAtPath:self.saveName]) {
        [fm createDirectoryAtPath:self.saveName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *savePath = [userPath stringByAppendingPathComponent:self.saveName];
    savePath = [savePath stringByAppendingPathComponent:self.saveName];
    
    //只能用set方法设定，不能用实例变量
    //_savePath = savePath;
    [self setSavePath:savePath];

    return _savePath;
}

- (NSString *)saveName {
    
    if (!_saveName) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy_MMdd_HHmmss"];
        
        NSDate *now = [NSDate date];
        NSString *nowStr = [formatter stringFromDate:now];
        
        self.saveName = nowStr;
        
        [formatter release];
    }
    
    return _saveName;
}

@end
