//
//  RudderFacebookIntegration.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 15/11/19.
//

#import "RudderFacebookIntegration.h"

static NSArray* events;

@implementation RudderFacebookIntegration

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client {
    self = [super init];
    if (self) {
        self.limitedDataUse = [config[@"limitedDataUse"] boolValue];
        self.dpoState = [config[@"dpoState"] intValue];
        self.dpoCountry = [config[@"dpoCountry"] intValue];
        
        events = @[@"identify", @"track", @"screen"];
        
        if (self.limitedDataUse) {
            [FBSDKSettings setDataProcessingOptions:@[@"LDU"] country:self.dpoCountry state:self.dpoState];
            [RSLogger logDebug:[NSString stringWithFormat:@"[FBSDKSettings setDataProcessingOptions:[%@] country:%d state:%d]",@"LDU", self.dpoCountry, self.dpoState]];
        } else {
            [FBSDKSettings setDataProcessingOptions:@[]];
            [RSLogger logDebug:@"[FBSDKSettings setDataProcessingOptions:[]"];
        }
    }
    return self;
}

- (void) processRuderEvent: (nonnull RSMessage *) message {
    int label = [events indexOfObject:message.type];
    switch(label)
    {
        case 0:
        {
            [FBSDKAppEvents setUserID:message.userId];
            NSDictionary *address = (NSDictionary*) message.context.traits[@"address"];
            [FBSDKAppEvents setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"email"]] forType:FBSDKAppEventEmail];
            [FBSDKAppEvents setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"firstName"]] forType:FBSDKAppEventFirstName];
            [FBSDKAppEvents setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"lastName"]] forType:FBSDKAppEventLastName];
            [FBSDKAppEvents setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"phone"]] forType:FBSDKAppEventPhone];
            [FBSDKAppEvents setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"birthday"]] forType:FBSDKAppEventDateOfBirth];
            [FBSDKAppEvents setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"gender"]] forType:FBSDKAppEventGender];
            [FBSDKAppEvents setUserData:[[NSString alloc] initWithFormat:@"%@", address[@"city"]] forType:FBSDKAppEventCity];
            [FBSDKAppEvents setUserData:[[NSString alloc] initWithFormat:@"%@", address[@"state"]] forType:FBSDKAppEventState];
            [FBSDKAppEvents setUserData:[[NSString alloc] initWithFormat:@"%@", address[@"postalcode"]] forType:FBSDKAppEventZip];
            [FBSDKAppEvents setUserData:[[NSString alloc] initWithFormat:@"%@", address[@"country"]] forType:FBSDKAppEventCountry];
            break;
        }
        case 1:
        {
            // FB Event Names must be <= 40 characters
            NSString *truncatedEvent = [message.event substringToIndex: MIN(40, [message.event length])];
            
            // Revenue & currency tracking
            NSNumber *revenue = [self extractRevenue:message.properties withKey:@"revenue"];
            NSString *currency = [self extractCurrency:message.properties withKey:@"currency"];
            
            if (revenue) {
                [FBSDKAppEvents logPurchase:[revenue doubleValue] currency:currency];
                
                // Custom event
                NSMutableDictionary *properties = [message.properties mutableCopy];
                [properties setObject:currency forKey:FBSDKAppEventParameterNameCurrency];
                [FBSDKAppEvents logEvent:truncatedEvent
                              valueToSum:[revenue doubleValue]
                              parameters:properties];
                
            }
            else {
                [FBSDKAppEvents logEvent:truncatedEvent
                              parameters:message.properties];
            }
            break;
        }
        case 2:
        {
            // FB Event Names must be <= 40 characters
            // 'Viewed' and 'Screen' with spaces take up 14
            NSString *truncatedEvent = [message.event substringToIndex: MIN(26, [message.event length])];
            NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", truncatedEvent];
            [FBSDKAppEvents logEvent:event parameters:message.properties];
            break;
        }
        default:
            [RSLogger logWarn:@"MessageType is not supported"];
            break;
    }
}


- (void)dump:(nonnull RSMessage *)message {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self processRuderEvent:message];
    }];
    
}

- (void)reset {
    [FBSDKAppEvents clearUserID];
    [FBSDKAppEvents clearUserData];
}

#pragma mark - Utils

- (NSNumber *)extractRevenue:(NSDictionary *)dictionary withKey:(NSString *)revenueKey
{
    id revenueProperty = nil;
    
    for (NSString *key in dictionary.allKeys) {
        if ([key caseInsensitiveCompare:revenueKey] == NSOrderedSame) {
            revenueProperty = dictionary[key];
            break;
        }
    }
    
    if (revenueProperty) {
        if ([revenueProperty isKindOfClass:[NSString class]]) {
            // Format the revenue.
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            return [formatter numberFromString:revenueProperty];
        }
        else if ([revenueProperty isKindOfClass:[NSNumber class]]) {
            return revenueProperty;
        }
    }
    return nil;
}

- (NSString *)extractCurrency:(NSDictionary *)dictionary withKey:(NSString *)currencyKey
{
    id currencyProperty = nil;
    
    for (NSString *key in dictionary.allKeys) {
        if ([key caseInsensitiveCompare:currencyKey] == NSOrderedSame) {
            currencyProperty = dictionary[key];
            return currencyProperty;
        }
    }
    
    // default to USD
    return @"USD";
}

#pragma mark - Callbacks for app state changes

- (void)applicationDidBecomeActive
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[FBSDKAppEvents alloc] activateApp];
    }];
}

@end
