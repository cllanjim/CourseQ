//
//  Course+Fetcher.h
//  CourseQ
//
//  Created by Jing on 13-5-23.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "Course.h"

@interface Course (Fetcher)

+ (Course *)courseWithCourseDictionary:(NSDictionary *)dic
           inManagedObjectContext:(NSManagedObjectContext *)context;

@end
