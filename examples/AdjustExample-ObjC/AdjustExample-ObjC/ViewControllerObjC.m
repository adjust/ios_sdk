//
//  ViewControllerObjC.m
//  AdjustExample-ObjC
//
//  Created by Pedro Filipe (@nonelse) on 12th October 2015.
//  Copyright © 2015-2019 Adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "Constants.h"
#import "ViewControllerObjC.h"

@interface ViewControllerObjC ()

@property (weak, nonatomic) IBOutlet UIButton *btnTrackSimpleEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackRevenueEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackCallbackEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackPartnerEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnEnableOfflineMode;
@property (weak, nonatomic) IBOutlet UIButton *btnDisableOfflineMode;
@property (weak, nonatomic) IBOutlet UIButton *btnEnableSdk;
@property (weak, nonatomic) IBOutlet UIButton *btnDisableSdk;
@property (weak, nonatomic) IBOutlet UIButton *btnIsSdkEnabled;

@end

@implementation ViewControllerObjC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)clickTrackSimpleEvent:(UIButton *)sender {
    ADJSubscription *subscription = [[ADJSubscription alloc]
                                     initWithRevenue:6.66
                                     currency:@"CAD"
                                     transactionDate:1234567890
                                     transactionId:@"random-transaction-id"
                                     andReceipt:[@"random-receipt" dataUsingEncoding:NSUTF8StringEncoding]];
    [subscription addCallbackParameter:@"foo" value:@"bar"];
    [subscription addCallbackParameter:@"key" value:@"value"];
    [subscription addPartnerParameter:@"foo" value:@"bar"];
    [subscription addPartnerParameter:@"key" value:@"value"];

    [Adjust trackSubscription:subscription];
}

- (IBAction)clickTrackRevenueEvent:(UIButton *)sender {
    NSURL __block *url = [NSURL URLWithString:@"random-url"];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // Add revenue 1 cent of an EURO.
//        for (int i = 0; i < 30000; i += 1) {
//            [event setRevenue:i currency:@"EUR"];
//            [event setCallbackId:[NSString stringWithFormat:@"%@%d", @"random-id", i]];
//            [event addCallbackParameter:@"foo" value:[NSString stringWithFormat:@"%@%d", @"bar", i]];
//            [event addCallbackParameter:@"key" value:[NSString stringWithFormat:@"%@%d", @"value", i]];
//        }
//    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 300; i += 1) {
            [Adjust appWillOpenUrl:[NSURL URLWithString:[NSString stringWithFormat:@"random-url-%d", i]]];
        }
    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // Add revenue 1 cent of an EURO.
//        for (int i = 30000; i < 60000; i += 1) {
//            url = [NSURL URLWithString:[NSString stringWithFormat:@"random-url-%d", i]];
//        }
//    });
}

- (IBAction)clickTrackCallbackEvent:(UIButton *)sender {
    ADJEvent *event = [ADJEvent eventWithEventToken:kEventToken3];

    // Add callback parameters to this event.
    [event addCallbackParameter:@"foo" value:@"bar"];
    [event addCallbackParameter:@"key" value:@"value"];

    [Adjust trackEvent:event];
}

- (IBAction)clickTrackPartnerEvent:(UIButton *)sender {
    ADJEvent *event = [ADJEvent eventWithEventToken:kEventToken4];

    // Add partner parameteres to this event.
    [event addPartnerParameter:@"foo" value:@"bar"];
    [event addPartnerParameter:@"key" value:@"value"];

    [Adjust trackEvent:event];
}

- (IBAction)clickEnableOfflineMode:(id)sender {
    [Adjust setOfflineMode:YES];
}

- (IBAction)clickDisableOfflineMode:(id)sender {
    [Adjust setOfflineMode:NO];
}

- (IBAction)clickEnableSdk:(id)sender {
    [Adjust setEnabled:YES];
}

- (IBAction)clickDisableSdk:(id)sender {
    [Adjust setEnabled:NO];
}

- (IBAction)clickIsSdkEnabled:(id)sender {
    NSString *message;

    if ([Adjust isEnabled]) {
        message = @"SDK is ENABLED!";
    } else {
        message = @"SDK is DISABLED!";
    }

    UIAlertView *alert = [[UIAlertView alloc ]initWithTitle:@"Is SDK Enabled?"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
}

@end
