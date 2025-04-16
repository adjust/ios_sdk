//
//  ViewController.m
//  AdjustTestApp
//
//  Created by Pedro Silva (@nonelse) on 23rd August 2017.
//  Copyright © 2017-2018 Adjust GmbH. All rights reserved.
//

#import "ViewController.h"
#import <AdjustSdk/AdjustSdk.h>
#import "ATLTestLibrary.h"
#import "ATAAdjustCommandExecutor.h"

@interface ViewController ()

@property (nonatomic, strong) ATLTestLibrary *testLibrary;
@property (nonatomic, strong) ATAAdjustCommandExecutor *adjustCommandExecutor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.adjustCommandExecutor = [[ATAAdjustCommandExecutor alloc] init];
    self.testLibrary = [ATLTestLibrary testLibraryWithBaseUrl:urlOverwrite
                                                andControlUrl:controlUrl
                                           andCommandDelegate:self.adjustCommandExecutor];
    [self.adjustCommandExecutor setTestLibrary:self.testLibrary];

    // [self.testLibrary addTestDirectory:@"deeplink"];
    // [self.testLibrary doNotExitAfterEnd];
    [self startTestSession];
}

- (void)startTestSession {
    [Adjust sdkVersionWithCompletionHandler:^(NSString * _Nullable sdkVersion) {
        [self.testLibrary startTestSession:sdkVersion];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)restartTestClick:(UIButton *)sender {
    [self startTestSession];
}

@end
