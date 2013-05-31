//
//  MongoRequest.h
//  WebSchool
//
//  Created by Fee Val on 13-3-9.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MongoRequest : NSObject

+ (NSString *)JSONCoursesWithMemberID:(NSString *)mID skip:(NSInteger)x range:(NSInteger)y;

+ (NSUInteger)likesWithCourseUID:(NSString *)uid;
+ (NSUInteger)hitsWithCourseUID:(NSString *)uid;
+ (NSUInteger)forwardWithCourseUID:(NSString *)uid;


@end
