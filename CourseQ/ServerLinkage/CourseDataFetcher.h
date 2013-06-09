//
//  CourseDataFetcher.h
//  WebSchool
//
//  Created by Fee Val on 13-5-24.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CQ_COURSE_FILENAME @"courseFilename"
#define CQ_COURSE_PAGENUMBER @"pageNumber"
#define CQ_COURSE_POSTDATE @"postDate"
#define CQ_COURSE_POSTER @"poster"
#define CQ_COURSE_POSTERID @"posterID"
#define CQ_COURSE_PORTRAIT @"posterPortrait"
#define CQ_COURSE_TITLE @"title"
#define CQ_COURSE_UID @"uID"
#define CQ_COURSE_CATEGORY @"category"
#define CQ_COURSE_LIKECOUNT @"likes"
#define CQ_COURSE_FORWARDCOUNT @"forwards"
#define CQ_COURSE_WEIGHTNESS @"weight"
#define CQ_COURSE_HITSCOUNT @"hits"

@interface CourseDataFetcher : NSObject

// 获取 跳过X条的后Y条 数组（数组内容是Dictionary） -按照时间的顺序降序，memberID为XX的用户关注的用户发布的课程
+ (NSArray *)courseDictionariesSkip:(NSInteger)x range:(NSInteger)y;
+ (NSArray *)courseDictionariesByWeightSkip:(NSInteger)x range:(NSInteger)y;

// 获取 跳过X条的后Y条 数组（数组内容是Dictionary） -按照时间的顺序降序，memberID为XX的用户关注的用户发布的课程
+ (NSArray *)courseDictionariesWithMemberID:(NSString *)mID skip:(NSInteger)x range:(NSInteger)y;

@end
