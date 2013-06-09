//
//  FilePathHelper.h
//  WebSchool
//
//  Created by Fee Val on 13-2-20.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilePathHelper : NSObject

//page
- (void)setCurrentPage:(NSInteger)page;
- (NSInteger)currentPage;

//path
- (NSString *)imagePath;
- (NSString *)thumbnailPath;
- (NSString *)audioPath;

@end
