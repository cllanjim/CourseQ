//
//  DataParser.m
//  WebSchool
//
//  Created by Fee Val on 12-11-13.
//  Copyright (c) 2012年 Freebox. All rights reserved.

#import "DataParser.h"

@implementation DataParser

+ (BOOL)loginApplication:(NSString *)requestString
{
    BOOL isLoginSuccess = NO;
    NSArray *loginArr = [requestString componentsSeparatedByString:SPLIT1];
    
    NSString *statusOfLogin = [loginArr objectAtIndex:1];
    if ([statusOfLogin isEqualToString:@"login success"])
    {
        isLoginSuccess = YES;
    }
    
    return isLoginSuccess;
}

+ (NSArray *)commonParser:(NSString *)requestString
{
    NSString *content = [[requestString componentsSeparatedByString:SPLIT1] objectAtIndex:1];
    NSArray *firstSP = [content componentsSeparatedByString:SPLIT2];
    NSMutableArray *compArrays = [NSMutableArray arrayWithCapacity:10];
    for (NSString *member in firstSP)
    {
        NSArray *arrOfmember = [member componentsSeparatedByString:SPLIT3];
        [compArrays addObject:arrOfmember];
    }
    return compArrays;
}

#define IMG_DIV @"<img alt="
#define IMG_DIVEND @"/>"
#define IMG_SRC @"src=\""

+ (NSString *)newsImagePath:(NSString *)requestString
{
    NSArray *contentArr = [DataParser newsParser:requestString];
    NSString *content;
    if ([contentArr count]>=2)
    {
        content = [[contentArr objectAtIndex:1]lowercaseString];
    }
    else
    {
        return NO_IMG;
    }
    
    NSRange arng = [content rangeOfString:IMG_DIV];
    
    if (arng.length == 0)
    {
        return NO_IMG;
    }
    
    NSString *sub1 = [content substringFromIndex:arng.location];
    NSRange rngEnd = [sub1 rangeOfString:IMG_DIVEND];
    NSString *sub2 = [sub1 substringToIndex:rngEnd.location];
    NSRange srcBegine = [sub2 rangeOfString:IMG_SRC];
    NSString *sub3 = [sub2 substringFromIndex:srcBegine.location];
    NSArray *tmpArr = [sub3 componentsSeparatedByString:@"\""];
    return [tmpArr objectAtIndex:1];
}

+ (NSArray *)newsParser:(NSString *)requestString
{
    NSString *content = [[requestString componentsSeparatedByString:SPLIT1] objectAtIndex:1];
    NSArray *newsInfo = [content componentsSeparatedByString:SPLIT3];
    return newsInfo;
}

+ (NSArray *)newsListParser:(NSString *)requestString
{
    NSMutableArray *idNewsList = [NSMutableArray arrayWithCapacity:0];
    NSArray *conentArr  = [DataParser commonParser:requestString];
    for (NSArray *arr in conentArr)
    {
        [idNewsList addObject:[arr objectAtIndex:0]];
    }
    
    // NSLog(@"====== ++%@++=====",idNewsList);
    return idNewsList;
}

#pragma mark - MongoDB

+ (NSString *)resultFromMongoDB:(NSString *)requestString{
    
    NSString *content = [[requestString componentsSeparatedByString:SPLIT1] lastObject];
    return content;
}

+ (NSString *)resultJsonStringFromMongoAggregateFollow:(NSString *)followAggregateResult{
    
    // MONGOSET=@:null@;MONGOAGGREGATE=@:[[{"=X=":["27","21","23"]}],1]
    NSString *operateJson =  [DataParser resultFromMongoDB:followAggregateResult];
    NSRange rng = NSMakeRange(9, [operateJson length] - 14);
    return [operateJson substringWithRange:rng];
}
@end
