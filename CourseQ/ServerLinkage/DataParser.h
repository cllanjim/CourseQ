//
//  DataParser.h
//  WebSchool
//
//  Created by Fee Val on 12-11-13.
//  Copyright (c) 2012年 Freebox. All rights reserved.
//

#define SPLIT0 @"@;" //返回：切割模块
#define SPLIT1 @"@:" //返回：切割请求和返回值
#define SPLIT2 @"@-" //返回：一级切割模块返回值；发送：连接本模块多参数
#define SPLIT3 @"@=" //返回：二级切割模块返回值

#define NO_IMG @"NOIMG"

// dataParser
#import <Foundation/Foundation.h>

@interface DataParser : NSObject

// login function
+ (BOOL)loginApplication:(NSString *)requestString;

// commonData 有待加强
+ (NSArray *)commonParser:(NSString *)requestString;

// news
+ (NSArray *)newsParser:(NSString *)requestString;
+ (NSString *)newsImagePath:(NSString *)requestString;
+ (NSArray *)newsListParser:(NSString *)requestString;

// MongoDB 返回结果
+ (NSString *)resultFromMongoDB:(NSString *)requestString;
+ (NSString *)resultJsonStringFromMongoAggregateFollow:(NSString *)followAggregateResult;

// 个人信息的Parser


@end
