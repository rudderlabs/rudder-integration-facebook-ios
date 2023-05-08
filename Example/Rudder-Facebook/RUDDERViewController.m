//
//  RUDDERViewController.m
//  Rudder-Facebook
//
//  Created by arnab on 11/15/2019.
//  Copyright (c) 2019 arnab. All rights reserved.
//

#import "RUDDERViewController.h"
#import <Rudder/Rudder.h>

@interface RUDDERViewController ()

@end

@implementation RUDDERViewController
RSClient *client;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    client = [RSClient getInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)identify:(id)sender {
    [client identify:@"iOSUserId"
                                 traits:@{@"address": [self getAddress],
                                          @"email": @"test@random.com",
                                          @"firstName": @"FName",
                                          @"lastName": @"LName",
                                          @"phone": @"1234567890",
                                          @"birthday": [NSDate date],
                                          @"gender": @"M"
                                        }];
}

- (IBAction)addedToCart:(id)sender {
    [client track:@"Product Added" properties:[self getAllStandardProperties]];
}

- (IBAction)AddedToWishlist:(id)sender {
    [client track:@"Product Added to Wishlist" properties:[self getAllStandardProperties]];
}

- (IBAction)ViewedContent:(id)sender {
    [client track:@"Product Viewed" properties:[self getAllStandardProperties]];
}

- (IBAction)InitiatedCheckout:(id)sender {
    [client track:@"Checkout Started" properties:[self getAllStandardProperties]];
}

- (IBAction)SpentCredits:(id)sender {
    [client track:@"Spend Credits" properties:[self getAllStandardProperties]];
}

- (IBAction)Purchased:(id)sender {
    [client track:@"Order Completed" properties:[self getAllStandardProperties]];
}

- (IBAction)Searched:(id)sender {
    [client track:@"Products Searched" properties:[self getAllStandardProperties]];
}

- (IBAction)AddedPaymentInfo:(id)sender {
    [client track:@"Payment Info Entered" properties:[self getAllStandardProperties]];
}

- (IBAction)CompletedRegistration:(id)sender {
    [client track:@"Complete Registration" properties:[self getAllStandardProperties]];
}

- (IBAction)AchievedLevel:(id)sender {
    [client track:@"Achieve Level" properties:[self getAllStandardProperties]];
}

- (IBAction)CompletedTutorial:(id)sender {
    [client track:@"Complete Tutorial" properties:[self getAllStandardProperties]];
}

- (IBAction)UnlockedAchievement:(id)sender {
    [client track:@"Unlock Achievement" properties:[self getAllStandardProperties]];
}

- (IBAction)Subscribe:(id)sender {
    [client track:@"Subscribe" properties:[self getAllStandardProperties]];
}

- (IBAction)StartTrial:(id)sender {
    [client track:@"Start Trial" properties:[self getAllStandardProperties]];
}

- (IBAction)AdClick:(id)sender {
    [client track:@"Promotion Clicked" properties:[self getAllStandardProperties]];
}

- (IBAction)AdImpression:(id)sender {
    [client track:@"Promotion Viewed" properties:[self getAllStandardProperties]];
}

- (IBAction)Rated:(id)sender {
    [client track:@"Product Reviewed" properties:[self getAllStandardProperties]];
}

- (IBAction)CustomTrackWithoutProperties:(id)sender {
    [client track:@"level_up"];
    [client track:@"custom track 2"];
}

- (IBAction)CustomTrackWithProperties:(id)sender {
    [client track:@"daily_rewards_claim" properties:[self getCustomProperties]];
}

- (IBAction)Screen:(id)sender {
    [client screen:@"View Controller 1"];
    [client screen:@"View Controller 2" properties:[self getCustomProperties]];
}

- (IBAction)RESET:(id)sender {
    [client reset];
}

-(NSDictionary *) getAddress {
    return @{
        @"city": @"Random City",
        @"state": @"Random State",
        @"country": @"Random Country"
    };
}

-(NSDictionary *) getAllStandardProperties {
    return @{
        @"price": @123,
        @"value": @124,
        @"revenue": @125,
        @"currency": @"INR",
        @"product_id": @"1001",
        @"rating": @5,
        @"name": @"AdTypeValue",
        @"order_id": @"2001",
        @"description": @"description value",
        @"query": @"query value",
        @"key-1": @123,
        @"key-2": @"value-1"
    };
}

-(NSDictionary *) getCustomProperties {
    return @{
        @"key-1": @123,
        @"key-2": @"value-1"
    };
}

@end
