//
//  RudderFacebookIntegration.h
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 15/11/19.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit_Basics/FBSDKUserDataStore.h>



NS_ASSUME_NONNULL_BEGIN

@interface RudderFacebookIntegration : NSObject<RSIntegration>

@property (nonatomic) BOOL limitedDataUse;
@property (nonatomic) int dpoState;
@property (nonatomic) int dpoCountry;

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client;

@end

NS_ASSUME_NONNULL_END
