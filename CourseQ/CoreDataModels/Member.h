//
//  Member.h
//  CourseQ
//
//  Created by Jing on 13-5-24.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Member : NSManagedObject

@property (nonatomic, retain) NSNumber * follow;
@property (nonatomic, retain) NSNumber * follower;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * memberID;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * portrait;

@end
