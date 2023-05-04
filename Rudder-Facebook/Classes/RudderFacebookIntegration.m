//
//  RudderFacebookIntegration.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 15/11/19.
//

#import "RudderFacebookIntegration.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

NSArray* events;

@implementation RudderFacebookIntegration

NSArray *TRACK_RESERVED_KEYWORDS;

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
        TRACK_RESERVED_KEYWORDS = [[NSArray alloc] initWithObjects:@"product_id", @"rating", @"name", @"order_id", @"currency", @"description", @"query", @"value", @"price", @"revenue", nil];
        
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
            NSString *eventName = [self getFacebookEvent: truncatedEvent];
 
            NSMutableDictionary<NSString *, id> *params = [[NSMutableDictionary alloc] init];
            [self handleCustomPropeties:message.properties params:params isScreenEvent:false];
        
            // Standard events, refer Facebook docs: https://developers.facebook.com/docs/app-events/reference#standard-events-2 for more info
            if ([eventName isEqualToString:FBSDKAppEventNameAddedToCart] || [eventName isEqualToString:FBSDKAppEventNameAddedToWishlist] || [eventName isEqualToString:FBSDKAppEventNameViewedContent]) {
                [self handleStandardProperties:message.properties params:params eventName:eventName];
                NSNumber *price = [self getValueToSumFromProperties:message.properties propertyKey:@"price"];
                if (price) {
                    [FBSDKAppEvents.shared logEvent:eventName valueToSum:[price doubleValue] parameters:params];
                }
            } else if ([eventName isEqualToString:FBSDKAppEventNameInitiatedCheckout] || [eventName isEqualToString:FBSDKAppEventNameSpentCredits]) {
                [self handleStandardProperties:message.properties params:params eventName:eventName];
                NSNumber *value = [self getValueToSumFromProperties:message.properties propertyKey:@"value"];
                if (value) {
                    [FBSDKAppEvents.shared logEvent:eventName valueToSum:[value doubleValue] parameters:params];
                }
            } else if ([eventName isEqualToString:FBSDKAppEventNamePurchased]) {
                [self handleStandardProperties:message.properties params:params eventName:eventName];
                NSNumber *revenue = [self getValueToSumFromProperties:message.properties propertyKey:@"revenue"];
                NSString *currency = [NSString stringWithFormat:@"%@", message.properties[@"currency"]];
                if (currency == nil) {
                    currency = @"USD";
                }
                if (revenue && currency) {
                    [FBSDKAppEvents.shared logPurchase:[revenue doubleValue] currency:currency parameters:params];
                }
            } else if ([eventName isEqualToString:FBSDKAppEventNameSearched] || [eventName isEqualToString:FBSDKAppEventNameAddedPaymentInfo] || [eventName isEqualToString:FBSDKAppEventNameCompletedRegistration] || [eventName isEqualToString:FBSDKAppEventNameAchievedLevel] || [eventName isEqualToString:FBSDKAppEventNameCompletedTutorial] || [eventName isEqualToString:FBSDKAppEventNameUnlockedAchievement] || [eventName isEqualToString:FBSDKAppEventNameSubscribe] || [eventName isEqualToString:FBSDKAppEventNameStartTrial] || [eventName isEqualToString:FBSDKAppEventNameAdClick] || [eventName isEqualToString:FBSDKAppEventNameAdImpression] || [eventName isEqualToString:FBSDKAppEventNameRated]) {
                [self handleStandardProperties:message.properties params:params eventName:eventName];
                [FBSDKAppEvents.shared logEvent:eventName parameters:params];
            } else {
                [FBSDKAppEvents.shared logEvent:eventName parameters:params];
            }
            break;
        }
        case 2:
        {
            // FB Event Names must be <= 40 characters
            // 'Viewed' and 'Screen' with spaces take up 14
            NSString *truncatedEvent = [message.event substringToIndex: MIN(26, [message.event length])];
            NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", truncatedEvent];
            NSMutableDictionary<NSString *, id> *params = [[NSMutableDictionary alloc] init];
            [self handleCustomPropeties:message.properties params:params isScreenEvent:true];
            [FBSDKAppEvents.shared logEvent:event parameters:params];
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

- (NSString *)getFacebookEvent:(NSString *)event {
    if ([event isEqualToString:@"Products Searched"]) {
        return FBSDKAppEventNameSearched;
    }
    if ([event isEqualToString:@"Product Viewed"]) {
        return FBSDKAppEventNameViewedContent;
    }
    if ([event isEqualToString:@"Product Added"]) {
        return FBSDKAppEventNameAddedToCart;
    }
    if ([event isEqualToString:@"Product Added to Wishlist"]) {
        return FBSDKAppEventNameAddedToWishlist;
    }
    if ([event isEqualToString:@"Payment Info Entered"]) {
        return FBSDKAppEventNameAddedPaymentInfo;
    }
    if ([event isEqualToString:@"Checkout Started"]) {
        return FBSDKAppEventNameInitiatedCheckout;
    }
    if ([event isEqualToString:@"Order Completed"]) {
        return FBSDKAppEventNamePurchased;
    }
    if ([event isEqualToString:@"Complete Registration"]) {
        return FBSDKAppEventNameCompletedRegistration;
    }
    if ([event isEqualToString:@"Achieve Level"]) {
        return FBSDKAppEventNameAchievedLevel;
    }
    if ([event isEqualToString:@"Complete Tutorial"]) {
        return FBSDKAppEventNameCompletedTutorial;
    }
    if ([event isEqualToString:@"Unlock Achievement"]) {
        return FBSDKAppEventNameUnlockedAchievement;
    }
    if ([event isEqualToString:@"Subscribe"]) {
        return FBSDKAppEventNameSubscribe;
    }
    if ([event isEqualToString:@"Start Trial"]) {
        return FBSDKAppEventNameStartTrial;
    }
    if ([event isEqualToString:@"Promotion Clicked"]) {
        return FBSDKAppEventNameAdClick;
    }
    if ([event isEqualToString:@"Promotion Viewed"]) {
        return FBSDKAppEventNameAdImpression;
    }
    if ([event isEqualToString:@"Spend Credits"]) {
        return FBSDKAppEventNameSpentCredits;
    }
    if ([event isEqualToString:@"Product Reviewed"]) {
        return FBSDKAppEventNameRated;
    }
    return event;
}

- (void) handleCustomPropeties: (NSDictionary *)properties params: (NSMutableDictionary<NSString *, id> *)params isScreenEvent: (BOOL)isScreenEvent {
    for (NSString *key in properties) {
        NSString *value = [properties objectForKey:key];
        if (!isScreenEvent && [TRACK_RESERVED_KEYWORDS containsObject:key]) {
            continue;
        }
        if ([value isKindOfClass:[NSNumber class]]) {
            params[key] = value;
        } else {
            params[key] = [NSString stringWithFormat:@"%@", value];
        }
    }
}

- (void) handleStandardProperties:(NSDictionary *)properties params: (NSMutableDictionary<NSString *, id> *)params eventName: (NSString *)eventName {
    NSString *productId = [NSString stringWithFormat:@"%@", properties[@"product_id"]];
    if (productId) {
        params[FBSDKAppEventParameterNameContentID] = productId;
    }
    
    NSNumber *rating = properties[@"rating"];
    if (rating) {
        params[FBSDKAppEventParameterNameMaxRatingValue] = rating;
    }
    
    NSString *name = [NSString stringWithFormat:@"%@", properties[@"name"]];
    if (name) {
        params[FBSDKAppEventParameterNameAdType] = name;
    }
    
    NSString *orderId = [NSString stringWithFormat:@"%@", properties[@"order_id"]];
    if (orderId) {
        params[FBSDKAppEventParameterNameOrderID] = orderId;
    }
    
        // For `Purchase` event we're directly handling the `currency` properties
    if (![eventName isEqualToString:FBSDKAppEventNamePurchased]) {
        NSString *currency = [NSString stringWithFormat:@"%@", properties[@"currency"]];
        if (currency) {
            params[FBSDKAppEventParameterNameCurrency] = currency;
        } else {
            currency = @"USD";
        }
    }
    
    NSString *description = [NSString stringWithFormat:@"%@", properties[@"description"]];
    if (description) {
        params[FBSDKAppEventParameterNameDescription] = description;
    }
    
    NSString *query = [NSString stringWithFormat:@"%@", properties[@"query"]];
    if (query) {
        params[FBSDKAppEventParameterNameSearchString] = query;
    }
}

- (NSNumber *)getValueToSumFromProperties:(NSDictionary *)properties propertyKey:(NSString *)propertyKey {
    if (properties != nil) {
        id value = [properties objectForKey:propertyKey];
        if (value != nil) {
            if ([value isKindOfClass:[NSNumber class]]) {
                return value;
            } else if ([value isKindOfClass:[NSString class]]) {
                return [NSNumber numberWithDouble:[value doubleValue]];
            }
        }
    }
    return nil;
}

#pragma mark - Callbacks for app state changes

- (void)applicationDidBecomeActive
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[FBSDKAppEvents alloc] activateApp];
    }];
}

@end
