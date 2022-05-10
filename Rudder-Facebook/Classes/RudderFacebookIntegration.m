//
//  RudderFacebookIntegration.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 15/11/19.
//

#import "RudderFacebookIntegration.h"

NSArray* events;

@implementation RudderFacebookIntegration

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client {
    self = [super init];
    if (self) {
        self.limitedDataUse = [config[@"limitedDataUse"] boolValue];
        self.dpoState = [config[@"dpoState"] intValue];
        if(self.dpoState != 0 && self.dpoState != 1000) {
            self.dpoState = 0;
        }
        self.dpoCountry = [config[@"dpoCountry"] intValue];
        if(self.dpoCountry != 0 && self.dpoCountry != 1) {
            self.dpoCountry = 0;
        }
        
        events = @[@"identify", @"track", @"screen"];
        
        if (self.limitedDataUse) {
            [FBSDKSettings.sharedSettings setDataProcessingOptions:@[@"LDU"] country:self.dpoCountry state:self.dpoState];
            [RSLogger logDebug:[NSString stringWithFormat:@"[FBSDKSettings setDataProcessingOptions:[%@] country:%d state:%d]",@"LDU", self.dpoCountry, self.dpoState]];
        } else {
            [FBSDKSettings.sharedSettings setDataProcessingOptions:@[]];
            [RSLogger logDebug:@"[FBSDKSettings setDataProcessingOptions:[]"];
        }
    }
    return self;
}

- (void) processRuderEvent: (nonnull RSMessage *) message {
    int label = (int) [events indexOfObject:message.type];
    switch(label)
    {
        case 0:
        {
            [FBSDKAppEvents.shared setUserID:message.userId];
            NSDictionary *address = (NSDictionary*) message.context.traits[@"address"];
            [FBSDKAppEvents.shared setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"email"]] forType:FBSDKAppEventEmail];
            [FBSDKAppEvents.shared setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"firstName"]] forType:FBSDKAppEventFirstName];
            [FBSDKAppEvents.shared setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"lastName"]] forType:FBSDKAppEventLastName];
            [FBSDKAppEvents.shared setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"phone"]] forType:FBSDKAppEventPhone];
            [FBSDKAppEvents.shared setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"birthday"]] forType:FBSDKAppEventDateOfBirth];
            [FBSDKAppEvents.shared setUserData:[[NSString alloc] initWithFormat:@"%@", message.context.traits[@"gender"]] forType:FBSDKAppEventGender];
            [FBSDKAppEvents.shared setUserData:[[NSString alloc] initWithFormat:@"%@", address[@"city"]] forType:FBSDKAppEventCity];
            [FBSDKAppEvents.shared setUserData:[[NSString alloc] initWithFormat:@"%@", address[@"state"]] forType:FBSDKAppEventState];
            [FBSDKAppEvents.shared setUserData:[[NSString alloc] initWithFormat:@"%@", address[@"postalcode"]] forType:FBSDKAppEventZip];
            [FBSDKAppEvents.shared setUserData:[[NSString alloc] initWithFormat:@"%@", address[@"country"]] forType:FBSDKAppEventCountry];
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
                [FBSDKAppEvents.shared logPurchase:[revenue doubleValue] currency:currency];
                
                // Custom event
                NSMutableDictionary *properties = [message.properties mutableCopy];
                [properties setObject:currency forKey:FBSDKAppEventParameterNameCurrency];
                [FBSDKAppEvents.shared logEvent:truncatedEvent
                              valueToSum:[revenue doubleValue]
                              parameters:properties];
                
            }
            else {
                [FBSDKAppEvents.shared logEvent:truncatedEvent
                              parameters:message.properties];
            }
            [FBSDKAppEvents.shared logEvent: FBSDKAppEventNameAddedToCart
                    valueToSum: 100.0
                    parameters: message.properties];
            break;
        }
        case 2:
        {
            // FB Event Names must be <= 40 characters
            // 'Viewed' and 'Screen' with spaces take up 14
            NSString *truncatedEvent = [message.event substringToIndex: MIN(26, [message.event length])];
            NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", truncatedEvent];
            [FBSDKAppEvents.shared logEvent:event parameters:message.properties];
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
    FBSDKAppEvents.shared.userID = nil;
    [FBSDKAppEvents.shared clearUserData];
}

- (void)flush {
    [RSLogger logDebug:@"Facebook App Events Factory doesn't support Flush Call"];
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
