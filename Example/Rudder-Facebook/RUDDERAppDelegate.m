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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import AppTrackingTransparency;

#import "Rudder_Facebook_Example-Swift.h"

@implementation RUDDERAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    /**
     * This code initializes the SDK when your app launches, and allows the SDK handle logins and sharing from the native Facebook app when you perform a Login or Share action. Otherwise, the user must be logged into Facebook to use the in-app browser to login. Refer Facebook App Event doc for more info: https://developers.facebook.com/docs/app-events/getting-started-app-events-ios
     */
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    // Make sure to set the delay of at least 1 second else pop-up will not appear.
    NSTimeInterval delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self requestTracking];
    });
    
    
    /// Copy the `SampleRudderConfig.plist` and rename it to`RudderConfig.plist` on the same directory.
    /// Update the values as per your need.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RudderConfig" ofType:@"plist"];
    if (path != nil) {
        NSURL *url = [NSURL fileURLWithPath:path];
        RudderConfig *rudderConfig = [RudderConfig createFrom:url];
        if (rudderConfig != nil) {
            RSConfigBuilder *configBuilder = [[RSConfigBuilder alloc] init];
            [configBuilder withDataPlaneUrl:rudderConfig.PROD_DATA_PLANE_URL];
            [configBuilder withLoglevel:RSLogLevelVerbose];
            [configBuilder withFactory:[RudderFacebookFactory instance]];
            [configBuilder withTrackLifecycleEvens:NO];
            [configBuilder withSleepTimeOut:3];
            [RSClient getInstance:rudderConfig.WRITE_KEY config:[configBuilder build]];
        }
    }
    return YES;
}

-(void) requestTracking {
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            switch (status){
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                    break;
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    FBSDKSettings.sharedSettings.isAutoLogAppEventsEnabled = true;
                    FBSDKSettings.sharedSettings.isAdvertiserTrackingEnabled = true;
                    FBSDKSettings.sharedSettings.isAdvertiserIDCollectionEnabled = true;
                    break;
            case ATTrackingManagerAuthorizationStatusDenied:
                    FBSDKSettings.sharedSettings.isAutoLogAppEventsEnabled = false;
                    FBSDKSettings.sharedSettings.isAdvertiserTrackingEnabled = false;
                    FBSDKSettings.sharedSettings.isAdvertiserIDCollectionEnabled = false;
                    break;
            default:
                    break;
            }
        }];
    }
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
