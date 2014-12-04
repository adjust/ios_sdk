//
//  ViewController.m
//  example
//
//  Created by Pedro Filipe on 18/11/14.
//  Copyright (c) 2014 adjust. All rights reserved.
//

#import "ViewController.h"
#import "Adjust.h"
#import "ExampleAdjustHelper.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnTrackEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnDisableSdk;
@property (weak, nonatomic) IBOutlet UIButton *btnSetOfflineMode;
@property (weak, nonatomic) IBOutlet UIButton *btnSetOnlineMode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    BOOL isEnabled = [Adjust isEnabled];
    if (!isEnabled) {
        [self.btnDisableSdk setTitle:@"Enable SDK" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickTrackEvent:(UIButton *)sender {
    [ExampleAdjustHelper triggerEvent];
}
- (IBAction)clickDisableSdk:(UIButton *)sender {
    NSString *txtDisableSdk = self.btnDisableSdk.titleLabel.text;

    if ([txtDisableSdk hasPrefix:@"Disable"]) {
        [Adjust setEnabled:NO];
    } else {
        [Adjust setEnabled:YES];
    }

    BOOL isEnabled = [Adjust isEnabled];
    if (!isEnabled) {
        [self.btnDisableSdk setTitle:@"Enable SDK" forState:UIControlStateNormal];
    } else {
        [self.btnDisableSdk setTitle:@"Disable SDK" forState:UIControlStateNormal];
    }
}
- (IBAction)clickSetOfflineMode:(UIButton *)sender {
    [Adjust setOfflineMode:YES];
}
- (IBAction)clickSetOnlineMode:(UIButton *)sender {
    [Adjust setOfflineMode:NO];
}

@end
