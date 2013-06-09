//
//  Unit.h
//  CourseQ
//
//  Created by Jing on 13-5-23.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Unit : NSManagedObject

@property (nonatomic, retain) NSString * audioPath;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * page;
@property (nonatomic, retain) Course *belongTo;

@end
