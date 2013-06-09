//
//  Course+Fetcher.m
//  CourseQ
//
//  Created by Jing on 13-5-23.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "Course+Fetcher.h"
#import "CourseDataFetcher.h"

static NSString *_WebAdressOfFreeboxWS_DONWLOAD_2_0 = @"http://kechengpai.com/microcourse/file/";

@implementation Course (Fetcher)

+ (Course *)courseWithCourseDictionary:(NSDictionary *)dic inManagedObjectContext:(NSManagedObjectContext *)context {

    Course *course = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uID" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"uID = %@", dic[CQ_COURSE_UID]];
    
    NSError *error = nil;
    NSArray *matches  = [context executeFetchRequest:request error:&error];
    
    if (!matches || [matches count] > 1) {
        //handle error
        
    }else if (![matches count]){
        
        course = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:context];
        
        
        course.uID = dic[CQ_COURSE_UID];
        course.posterID = dic[CQ_COURSE_POSTERID];
        course.poster = dic[CQ_COURSE_POSTER];
        course.posterPortrait = dic[CQ_COURSE_PORTRAIT];
        course.title = dic[CQ_COURSE_TITLE];
        course.postDate = dic[CQ_COURSE_POSTDATE];
        course.pageNumber = dic[CQ_COURSE_PAGENUMBER];
        course.courseFileName = dic[CQ_COURSE_FILENAME];
        course.category = dic[CQ_COURSE_CATEGORY];
        course.likeCount = dic[CQ_COURSE_LIKECOUNT];
        course.hitCount = dic[CQ_COURSE_HITSCOUNT];
        course.forwardCount = dic[CQ_COURSE_FORWARDCOUNT];
        course.isFollowed = YES;
        
        
        //save thumbnail to local file
        NSString *thumbnailServerName = [course.courseFileName stringByAppendingFormat:@"_thumb.jpg"];
        NSString *thumbnailServerPath= [[NSString stringWithFormat:@"%@",_WebAdressOfFreeboxWS_DONWLOAD_2_0] stringByAppendingString:thumbnailServerName];
        NSURL *url = [NSURL URLWithString:thumbnailServerPath];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        //write to local file
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *thumbnailLocalPath = [documentPath stringByAppendingPathComponent:thumbnailServerName];
        [data writeToFile:thumbnailLocalPath atomically:YES];
        
        course.thumbnailPath = thumbnailLocalPath;
        
    }else{
        
        course = [matches lastObject];
    }
    
    return course;
}

@end
