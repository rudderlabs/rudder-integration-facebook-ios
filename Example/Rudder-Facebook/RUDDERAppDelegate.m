//
//  RUDDERAppDelegate.m
//  Rudder-Facebook
//
//  Created by arnab on 11/15/2019.
//  Copyright (c) 2019 arnab. All rights reserved.
//

#import "RUDDERAppDelegate.h"
#import <Rudder/Rudder.h>
#import <RudderFacebookFactory.h>
#import "FBSDKCoreKit.h"

@implementation RUDDERAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    NSString *writeKey = @"1vqBRSLN79i8T7Mcl6zzRsWqdO8";
    NSString *dataPlaneUrl = @"https://8469dc164c06.ngrok.io";

    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [FBSDKSettings setAdvertiserTrackingEnabled:YES];
    
    RSConfigBuilder *configBuilder = [[RSConfigBuilder alloc] init];
    [configBuilder withDataPlaneUrl:dataPlaneUrl];
    [configBuilder withFactory:[RudderFacebookFactory instance]];
    RSClient *rudderClient = [RSClient getInstance:writeKey config:[configBuilder build]];
    
    [rudderClient track:@"level_up"];
    [rudderClient track:@"daily_rewards_claim"];
    [rudderClient track:@"revenue"];
    
    [rudderClient screen:@"Main Screen"];
    [[RSClient sharedInstance] identify:@"test_user_id"
                                 traits:@{@"foo": @"bar",
                                          @"foo1": @"bar1",
                                          @"email": @"test@gmail.com",
                                          @"key_1" : @"value_1",
                                          @"key_2" : @"value_2"
                                 }
     ];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
