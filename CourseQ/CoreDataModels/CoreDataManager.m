//
//  CoreDataManager.m
//  CourseQ
//
//  Created by Jing on 13-6-5.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "CoreDataManager.h"
#import <CoreData/CoreData.h>

@interface CoreDataManager ()

@end

static CoreDataManager *cdm = nil;

@implementation CoreDataManager

- (UIManagedDocument *)managedDocument
{
    if (!_managedDocument) {
        
        NSLog(@"u = %@", [self.documentURL path]);
        _managedDocument = [[[UIManagedDocument alloc] initWithFileURL:self.documentURL] autorelease];
        [_managedDocument retain];
    }
    
    return _managedDocument;
}

- (NSURL *)documentURL
{
    if (!_documentURL) {
        NSFileManager *fm = [NSFileManager defaultManager];
        _documentURL = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _documentURL = [_documentURL URLByAppendingPathComponent:@"CourseDocument"];
        [_documentURL retain];
    }
    
    return _documentURL;
}

#pragma mark - singleton

+ (id)sharedInstance
{
    if (cdm == nil) {
        cdm = [[super allocWithZone:NULL] init];
    }
    
    return cdm;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    
}

- (id)autorelease
{
    return self;
}

@end
