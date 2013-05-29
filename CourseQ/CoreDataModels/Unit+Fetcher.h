//
//  Unit+Fetcher.h
//  CourseQ
//
//  Created by Jing on 13-5-27.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "Unit.h"

@interface Unit (Fetcher)

+ (Unit *)unitWithUnitDictionary:(NSDictionary *)dic
              withCourseFileName:(NSString *)name
          inManagedObjectContext:(NSManagedObjectContext *)context;

@end
