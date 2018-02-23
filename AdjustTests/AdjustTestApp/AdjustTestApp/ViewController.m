//
//  ViewController.m
//  AdjustTestApp
//
//  Created by Pedro on 23.08.17.
//  Copyright © 2017 adjust. All rights reserved.
//

#import "ViewController.h"
#import "Adjust.h"
#import "ATLTestLibrary.h"
#import "ATAAdjustCommandExecutor.h"
#import "ADJAdjustFactory.h"

@interface ViewController ()
@property (nonatomic, strong) ATLTestLibrary * testLibrary;
@property (nonatomic, strong) ATAAdjustCommandExecutor * adjustCommandExecutor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.adjustCommandExecutor = [[ATAAdjustCommandExecutor alloc] init];

    self.testLibrary = [ATLTestLibrary testLibraryWithBaseUrl:baseUrl andCommandDelegate:self.adjustCommandExecutor];

    [self.adjustCommandExecutor setTestLibrary:self.testLibrary];

    // [self.testLibrary addTestDirectory:@"current/sdkInfo"];
    // [self.testLibrary addTest:@"current/appSecret/Test_AppSecret_no_secret"];

    [self startTestSession];
}

- (void)startTestSession {
    [self.testLibrary startTestSession:@"ios4.12.3"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)restartTestClick:(UIButton *)sender {
    [self startTestSession];
}


@end
