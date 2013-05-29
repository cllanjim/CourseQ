//
//  Course.h
//  CourseQ
//
//  Created by Jing on 13-5-28.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Unit;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * courseFileName;
@property (nonatomic, retain) NSString * forwardCount;
@property (nonatomic, retain) NSString * hitCount;
@property (nonatomic, retain) NSString * likeCount;
@property (nonatomic, retain) NSString * pageNumber;
@property (nonatomic, retain) NSString * postDate;
@property (nonatomic, retain) NSString * poster;
@property (nonatomic, retain) NSString * posterID;
@property (nonatomic, retain) NSString * posterPortrait;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uID;
@property (nonatomic, retain) NSString * thumbnailPath;
@property (nonatomic, retain) NSSet *units;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addUnitsObject:(Unit *)value;
- (void)removeUnitsObject:(Unit *)value;
- (void)addUnits:(NSSet *)values;
- (void)removeUnits:(NSSet *)values;

@end
