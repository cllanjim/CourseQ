//
//  CourseDataFetcher.m
//  WebSchool
//
//  Created by Fee Val on 13-5-24.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import "CourseDataFetcher.h"
#import "MongoRequest.h"

@implementation CourseDataFetcher

+ (NSArray *)courseDictionariesSkip:(NSInteger)x range:(NSInteger)y{
    
    //拿到课程数据
    NSString * jsonString = [MongoRequest JSONCoursesSkip:x range:y];
    
    NSError *error = nil; // 创建一个Error的指针，以便解析错误的时候报错
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *result = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error]];// 加入出错处理
    
    if (error && result == nil) {
        NSLog(@"error :%@", [error localizedDescription]);
    }
    
    return result;
}

+ (NSArray *)courseDictionariesByWeightSkip:(NSInteger)x range:(NSInteger)y{
    
    //拿到课程数据
    NSString * jsonString = [MongoRequest JSONCoursesByWeightnessSkip:x range:y];
    
    NSError *error = nil; // 创建一个Error的指针，以便解析错误的时候报错
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *result = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error]];// 加入出错处理
    
    if (error && result == nil) {
        NSLog(@"error :%@", [error localizedDescription]);
    }
    
    return result;
}

+ (NSArray *)courseDictionariesWithMemberID:(NSString *)mID skip:(NSInteger)x range:(NSInteger)y {
    
    //拿到y条课程数据，但不包括3个社交信息，所以要通过课程的ID再拿到这3个社交信息
    
    
    //拿到课程数据
    NSString * jsonString = [MongoRequest JSONCoursesWithMemberID:mID skip:x range:y];
    
    NSError *error = nil; // 创建一个Error的指针，以便解析错误的时候报错
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arr = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error]];// 加入出错处理
    
    if (error) {
        NSLog(@"error :%@", [error localizedDescription]);
    }
    
    //拿到3个社交信息
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary *dic in arr) {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSString *uid = tmpDic[CQ_COURSE_UID];
        
        NSUInteger likeCount = [MongoRequest likesWithCourseUID:uid];
        NSUInteger hitsCount = [MongoRequest hitsWithCourseUID:uid];
        NSUInteger forwardCount = [MongoRequest forwardWithCourseUID:uid];
        
        // 以下三条数据不是直接从mongoDB中获得，而是要另外提交请求并且统计，可能会影响获取数据的速度。
        // 复制刚刚解析的数组中的字典到临时的可变的字典后，统计以下三项键入字典，再塞到另一个可变数组中，作为结果返回。
        [tmpDic setObject:[NSString stringWithFormat:@"%u",likeCount] forKey:CQ_COURSE_LIKECOUNT];
        [tmpDic setObject:[NSString stringWithFormat:@"%u",hitsCount] forKey:CQ_COURSE_HITSCOUNT];
        [tmpDic setObject:[NSString stringWithFormat:@"%u",forwardCount] forKey:CQ_COURSE_FORWARDCOUNT];
        [result addObject:tmpDic];
    }
    
    return result;
}

@end
