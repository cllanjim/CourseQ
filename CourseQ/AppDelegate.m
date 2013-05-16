//
//  AppDelegate.m
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "AppDelegate.h"

#import "RootViewController.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_rootVC release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.rootVC = [[[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.rootVC;
    [self.window setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0.9 alpha:1]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
