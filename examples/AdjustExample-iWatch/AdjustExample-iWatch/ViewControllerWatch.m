//
//  ViewControllerWatch.m
//  AdjustExample-iWatch
//
//  Created by Uglješa Erceg (@uerceg) on 6th April 2016
//  Copyright © 2016-Present Adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ViewControllerWatch.h"
#import "AdjustTrackingHelper.h"

@interface ViewControllerWatch ()

@property (weak, nonatomic) IBOutlet UIButton *btnTrackSimpleEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackRevenueEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackEventWithCallback;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackEventWithPartner;

@end

@implementation ViewControllerWatch

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)btnTrackSimpleEventTapped:(UIButton *)sender {
    [[AdjustTrackingHelper sharedInstance] trackSimpleEvent];
}
- (IBAction)btnTrackRevenueEventTapped:(UIButton *)sender {
    [[AdjustTrackingHelper sharedInstance] trackRevenueEvent];
}
- (IBAction)btnTrackCallbackEventTapped:(UIButton *)sender {
    [[AdjustTrackingHelper sharedInstance] trackCallbackEvent];
}
- (IBAction)btnTrackPartnerEventTapped:(UIButton *)sender {
    [[AdjustTrackingHelper sharedInstance] trackPartnerEvent];
}

@end
