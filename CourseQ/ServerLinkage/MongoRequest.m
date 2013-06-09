//
//  MongoRequest.m
//  WebSchool
//
//  Created by Fee Val on 13-3-9.
//  Copyright (c) 2013年 Freebox. All rights reserved.
//

#import "MongoRequest.h"
#import "ASIFormDataRequest.h"
#import "DataParser.h"
#import "ConstantDefinition.h"

@interface MongoRequest () <ASIHTTPRequestDelegate>

@end

@implementation MongoRequest

#pragma mark - request

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"request finish");
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"request fail: %@", [[request error] localizedDescription]);
}

#pragma mark -

+ (NSString *)JSONCourses{
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_WebAdressOfFreeboxWS_DataMongo_REQ_2_0]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"followcourse" forKey:@"operation"];
    [request startSynchronous];
    
    NSString *result = [NSString stringWithString:[request responseString]];
    
    return result;
}

+ (NSString *)JSONCoursesSkip:(NSInteger)x range:(NSInteger)y{
    
    NSString *skipX = [NSString stringWithFormat:@"%d",x];
    NSString *rangeY = [NSString stringWithFormat:@"%d",y];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_WebAdressOfFreeboxWS_DataMongo_REQ_2_0]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"followcourse" forKey:@"operation"];
    [request setPostValue:skipX forKey:@"skipx"];
    [request setPostValue:rangeY forKey:@"rangey"];
    [request startSynchronous];
    
    NSString *result = [NSString stringWithString:[request responseString]];
    
    // NSLog(@"%@",result);
    return result;
}

+ (NSString *)JSONCoursesWithMemberID:(NSString *)mID skip:(NSInteger)x range:(NSInteger)y {
    
    MongoRequest *mongoPostReq = [[MongoRequest new] autorelease];
    NSString *jsonArrOfFollowed = [mongoPostReq followersJSONWithMemberID:mID];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_WebAdressOfFreeboxWS_MongoDB_REQ_2_0]];
    [request setRequestMethod:@"POST"];
    NSString *mongoFind = [NSString stringWithFormat:@"[{\"posterID\":{\"$in\":%@}},{\"_id\":0,\"likeJsonArr\":0}]@-%d@-@-{\"postDate\":-1}",jsonArrOfFollowed,x];
    [request setPostValue:@"MclistTest@-demo" forKey:@"MONGOSET"];
    [request setPostValue:mongoFind forKey:@"MONGOFIND"];
    [request startSynchronous];
    
    NSString *result = [NSString stringWithString:[DataParser resultFromMongoDB:[request responseString]]];
    
    return result;
}

+ (NSString *)JSONCoursesByWeightness{
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_WebAdressOfFreeboxWS_DataMongo_REQ_2_0]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"weight" forKey:@"operation"];
    [request startSynchronous];
    NSString *result = [NSString stringWithString:[request responseString]];
    
    return result;
}

+ (NSString *)JSONCoursesByWeightnessSkip:(NSInteger)x range:(NSInteger)y{
    
    NSString *skipX = [NSString stringWithFormat:@"%d",x];
    NSString *rangeY = [NSString stringWithFormat:@"%d",y];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_WebAdressOfFreeboxWS_DataMongo_REQ_2_0]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"weight" forKey:@"operation"];
    [request setPostValue:skipX forKey:@"skipx"];
    [request setPostValue:rangeY forKey:@"rangey"];
    [request startSynchronous];
    NSString *result = [NSString stringWithString:[request responseString]];
    
    return result;
}

#pragma mark - inner function

- (NSString *)followersJSONWithMemberID:(NSString *)mID {
    
    //request
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_WebAdressOfFreeboxWS_MongoDB_REQ_2_0]];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    
    
    NSString *mongoAggregateStr =[NSString stringWithFormat:@"[{\"$match\":{\"memberID\":\"%@\"}},{\"$project\":{\"_id\":0,\"=X=\":\"$followJsonArr\"}}]", mID];
    [request setPostValue:@"MclistTest@-Members" forKey:@"MONGOSET"];
    [request setPostValue:mongoAggregateStr forKey:@"MONGOAGGREGATE"];
    [request startSynchronous];
    
    NSString *result = [NSString stringWithString:[DataParser resultJsonStringFromMongoAggregateFollow:[request responseString]]];
    
    return result;
}

#pragma mark - 3 social

+ (NSUInteger)hitsWithCourseUID:(NSString *)uid {
    
    //request
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_WebAdressOfFreeboxWS_MongoDB_REQ_2_0]];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    
    NSString *mongoFind = [NSString stringWithFormat:@"[{\"uID\":\"%@\"},{\"_id\":0,\"hits\":1}]", uid];
    [request setPostValue:@"MclistTest@-demo" forKey:@"MONGOSET"];
    [request setPostValue:mongoFind forKey:@"MONGOFIND"];
    [request startSynchronous];
    
    //
    NSString *result = [DataParser resultFromMongoDB:[request responseString]];
    
    NSUInteger hits = 0;
    if ([result isEqualToString:@"[[]]"] || [result isEqualToString:@"[]"] || [result isEqualToString:@"{}"] || [result isEqualToString:@""])
    {
    }
    else{
        NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:&error];
        
        NSDictionary *dic = resultArray[0];
        hits = [dic[@"hits"] unsignedIntValue];
    }
    
    return hits;
}

+ (NSUInteger)likesWithCourseUID:(NSString *)uid {
    
    //request
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_WebAdressOfFreeboxWS_MongoDB_REQ_2_0]];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    
    NSString *mongoAggregateStr = [NSString stringWithFormat:@"[{\"$match\":{\"uID\":\"%@\"}},{\"$unwind\":\"$likeJsonArr\"},{\"$project\":{\"count\":{\"$add\":1}}},{\"$group\":{\"_id\":0,\"number\":{\"$sum\":\"$count\"}}}]", uid];
    [request setPostValue:@"MclistTest@-demo" forKey:@"MONGOSET"];
    [request setPostValue:mongoAggregateStr forKey:@"MONGOAGGREGATE"];
    [request startSynchronous];
    
    //数组里面嵌数组，我们要的是第0项
    NSString *result = [DataParser resultFromMongoDB:[request responseString]];
    NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:&error];
    
    NSArray *likeCountArray = resultArray[0];
    NSUInteger likes = 0;
    
    if ([likeCountArray count]) {
        NSDictionary *dic = likeCountArray[0];
        likes = [dic[@"number"] unsignedIntValue];
    }
    
    return likes;
}

+(NSUInteger)forwardWithCourseUID:(NSString *)uid {
    
    //request
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_WebAdressOfFreeboxWS_MongoDB_REQ_2_0]];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    
    NSString *mongoFind = [NSString stringWithFormat:@"[{\"uID\":\"%@\"},{\"_id\":0,\"forwards\":1}]", uid];
    [request setPostValue:@"MclistTest@-demo" forKey:@"MONGOSET"];
    [request setPostValue:mongoFind forKey:@"MONGOFIND"];
    [request startSynchronous];
    
    //
    NSString *result = [DataParser resultFromMongoDB:[request responseString]];
    
    NSUInteger forward = 0;
    if ([result isEqualToString:@"[[]]"] || [result isEqualToString:@"[]"] || [result isEqualToString:@"{}"] || [result isEqualToString:@""])
    {
    }
    else{
        
        NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:&error];
        
        NSDictionary *dic = resultArray[0];
        forward = [dic[@"hits"] unsignedIntValue];
    }
    
    return forward;
    
}


@end
