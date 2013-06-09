//
//  CoreDataManager.h
//  CourseQ
//
//  Created by Jing on 13-6-5.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

@property (retain, nonatomic) UIManagedDocument *managedDocument;
@property (retain, nonatomic) NSURL *documentURL;

+ (id)sharedInstance;

@end
