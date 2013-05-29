//
//  Unit+Fetcher.m
//  CourseQ
//
//  Created by Jing on 13-5-27.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#define CQ_UNIT_IMGPATH @"imgLocalPath"
#define CQ_UNIT_SNDPATH @"sndLocalPath"
#define CQ_UNIT_PAGE @"pageNumber"

#import "Unit+Fetcher.h"
#import "Course.h"

@implementation Unit (Fetcher)

+ (Unit *)unitWithUnitDictionary:(NSDictionary *)dic withCourseFileName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context {

    Unit *unit = nil;
    
    unit = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:context];
    
    unit.imagePath = dic[CQ_UNIT_IMGPATH];
    unit.audioPath = dic[CQ_UNIT_SNDPATH];
    unit.page = dic[CQ_UNIT_PAGE];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    request.predicate = [NSPredicate predicateWithFormat:@"courseFileName = %@", name];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] == 1) {
        unit.belongTo = [matches lastObject];
    }
    else {
        NSLog(@"unitError:%@", [error localizedDescription]);
    }
    
    return unit;
}

@end
