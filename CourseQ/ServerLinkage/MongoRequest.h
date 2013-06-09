//
//  MongoRequest.h
//  WebSchool
//
//  Created by Fee Val on 13-3-9.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MongoRequest : NSObject

// new request from mongo.php

// 获取Json数据——当前登陆用户（必须登陆）所关注的人（包括自己）发布的微课，默认为按时间排序的前20条
+ (NSString *)JSONCourses;
// 获取Json数据——当前登陆用户（必须登陆）所关注的人（包括自己）发布的微课，默认为按时间排序的跳过x条之后取y条数据
+ (NSString *)JSONCoursesSkip:(NSInteger)x range:(NSInteger)y;

// 获取Json数据——课程广场
+ (NSString *)JSONCoursesByWeightness;   // 获取最新的20条课程广场数据（默认）
// 获取Json数据——课程广场,按权重，时间获取课程广场中跳过x条之后的y条数据
+ (NSString *)JSONCoursesByWeightnessSkip:(NSInteger)x range:(NSInteger)y;

+ (NSString *)JSONCoursesWithMemberID:(NSString *)mID skip:(NSInteger)x range:(NSInteger)y;
+ (NSUInteger)likesWithCourseUID:(NSString *)uid;
+ (NSUInteger)hitsWithCourseUID:(NSString *)uid;
+ (NSUInteger)forwardWithCourseUID:(NSString *)uid;


@end
