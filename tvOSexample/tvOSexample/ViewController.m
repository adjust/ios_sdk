//
//  ViewController.m
//  tvOSexample
//
//  Created by Pedro Filipe on 06/10/15.
//  Copyright © 2015 adjust. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnTrackSimpleEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackRevenueEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackEventWithCallback;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackEventWithPartner;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickTrackSimpleEvent:(UIButton *)sender {
    ADJEvent *event = [ADJEvent eventWithEventToken:@"{YourEventToken}"];

    [Adjust trackEvent:event];
}
- (IBAction)clickTrackRevenueEvent:(UIButton *)sender {
    ADJEvent *event = [ADJEvent eventWithEventToken:@"{YourEventToken}"];

    // add revenue 1 cent of an euro
    [event setRevenue:0.015 currency:@"EUR"];

    [Adjust trackEvent:event];
}
- (IBAction)clickEventWithCallback:(UIButton *)sender {
    ADJEvent *event = [ADJEvent eventWithEventToken:@"{YourEventToken}"];

    // add callback parameters to this parameter
    [event addCallbackParameter:@"key" value:@"value"];

    [Adjust trackEvent:event];
}
- (IBAction)clickEventWithPartner:(UIButton *)sender {
    ADJEvent *event = [ADJEvent eventWithEventToken:@"{YourEventToken}"];

    // add partner parameteres to all events and sessions
    [event addPartnerParameter:@"foo" value:@"bar"];

    [Adjust trackEvent:event];
}

@end
