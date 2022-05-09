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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)track:(id)sender {
    
    [[RSClient sharedInstance] identify:@"test_user_id"
                                 traits:@{@"foo": @"bar",
                                          @"foo1": @"bar1",
                                          @"email": @"test@gmail.com",
                                          @"key_1" : @"value_1",
                                          @"key_2" : @"value_2"
                                 }
     ];
    
    
    [[RSClient sharedInstance] track:@"level_up"];
    [[RSClient sharedInstance] track:@"daily_rewards_claim" properties:@{
        @"revenue":@"346",
        @"name":@"tyres"
    }];
    [[RSClient sharedInstance] track:@"revenue"];
    
    [[RSClient sharedInstance] screen:@"Main Screen"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
