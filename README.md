# What is RudderStack?

[RudderStack](https://rudderstack.com/) is a **customer data pipeline** tool for collecting, routing and processing data from your websites, apps, cloud tools, and data warehouse.

More information on RudderStack can be found [here](https://github.com/rudderlabs/rudder-server).

## Integrating Facebook with RudderStack's iOS SDK

1. Add [Facebook](http://Facebook.google.com) as a destination in the [Dashboard](https://app.rudderstack.com/).

2. Rudder-Facebook is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your Podfile and followed by `pod install`:

```ruby
pod 'Rudder-Facebook'
```

## Initialize ```RSClient```

Put the following code in your ```AppDelegate.m``` file under the method ```didFinishLaunchingWithOptions```:

```
RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
[builder withDataPlaneUrl:DATA_PLANE_URL];
[builder withFactory:[RudderFacebookFactory instance]];
[RSClient getInstance:WRITE_KEY config:[builder build]];
```

3. To enable the sending of events to Facebook App Events on iOS 14+ app MUST request user for tracking:

Put the following snippet in your ```AppDelegate.m``` file under the method ```didFinishLaunchingWithOptions```:
```
NSTimeInterval delayInSeconds = 1.0;
dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self requestTracking];
    });
```

Then put the below snippet in your ```AppDelegate.m``` file
```
-(void) requestTracking {
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            switch (status){
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                    break;
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    [FBSDKSettings.sharedSettings setAutoLogAppEventsEnabled:true];
                    [FBSDKSettings.sharedSettings setAdvertiserTrackingEnabled:true];
                    [FBSDKSettings.sharedSettings setAdvertiserIDCollectionEnabled:true];
                    break;
            case ATTrackingManagerAuthorizationStatusDenied:
                    [FBSDKSettings.sharedSettings setAutoLogAppEventsEnabled:false];
                    [FBSDKSettings.sharedSettings setAdvertiserTrackingEnabled:false];
                    [FBSDKSettings.sharedSettings setAdvertiserIDCollectionEnabled:false];
                    break;
            default:
                    break;
            }
        }];
    }
}
```


## Send Events
Follow the steps from the [RudderStack iOS SDK](https://github.com/rudderlabs/rudder-sdk-ios).

## Contact Us

If you come across any issues while configuring or using this integration, please feel free to [start a conversation on our [Slack](https://resources.rudderstack.com/join-rudderstack-slack) channel. We will be happy to help you.
