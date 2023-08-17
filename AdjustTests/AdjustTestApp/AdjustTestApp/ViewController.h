//
//  ViewController.h
//  AdjustTestApp
//
//  Created by Pedro Silva (@nonelse) on 23rd August 2017.
//  Copyright © 2017-2018 Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

// simulator
static NSString * baseUrl = @"http://127.0.0.1:8080";
static NSString * gdprUrl = @"http://127.0.0.1:8080";
static NSString * subscriptionUrl = @"http://127.0.0.1:8080";
static NSString * purchaseVerificationUrl = @"http://127.0.0.1:8080";
static NSString * controlUrl = @"ws://127.0.0.1:1987";
// device
//static NSString * baseUrl = @"http://192.168.86.44:8080";
//static NSString * gdprUrl = @"http://192.168.86.44:8080";
//static NSString * subscriptionUrl = @"http://192.168.86.44:8080";
//static NSString * purchaseVerificationUrl = @"http://192.168.86.44:8080";
//static NSString * controlUrl = @"ws://192.168.86.44:1987";

@interface ViewController : UIViewController

@end
