//
//  AppDelegate.m
//  MessageBarManagerDemo
//
//  Created by Terry Worona on 5/13/13.
//  Copyright (c) 2013 Terry Worona. All rights reserved.
//

#import "AppDelegate.h"

// Controllers
#import "TWMesssageBarDemoController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[TWMesssageBarDemoController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
