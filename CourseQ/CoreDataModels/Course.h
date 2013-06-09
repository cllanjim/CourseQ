//
//  Course.h
//  CourseQ
//
//  Created by Jing on 13-6-8.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Unit;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * courseFileName;
@property (nonatomic) int64_t forwardCount;
@property (nonatomic) int64_t hitCount;
@property (nonatomic) BOOL isFollowed;
@property (nonatomic) int64_t likeCount;
@property (nonatomic, retain) NSString * pageNumber;
@property (nonatomic, retain) NSString * postDate;
@property (nonatomic, retain) NSString * poster;
@property (nonatomic, retain) NSString * posterID;
@property (nonatomic, retain) NSString * posterPortrait;
@property (nonatomic, retain) NSString * thumbnailPath;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uID;
@property (nonatomic) int64_t weightness;
@property (nonatomic, retain) NSSet *units;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addUnitsObject:(Unit *)value;
- (void)removeUnitsObject:(Unit *)value;
- (void)addUnits:(NSSet *)values;
- (void)removeUnits:(NSSet *)values;

@end
