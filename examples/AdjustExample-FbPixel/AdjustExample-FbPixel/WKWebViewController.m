//
//  WKWebViewController.m
//  AdjustExample-WebView
//
//  Created by Uglješa Erceg on 31/05/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "WKWebViewController.h"

@interface WKWebViewController ()

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadWKWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadWKWebView {
    
    WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame];
    _adjustBridge = [[AdjustBridge alloc] init];
    [_adjustBridge loadWKWebViewBridge:wkWebView wkWebViewDelegate:self];
    [_adjustBridge augmentHybridWebView];


    NSString *path = [[NSBundle mainBundle] pathForResource:@"AdjustExample-FbPixel" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [wkWebView loadRequest:request];
    [self.view addSubview:wkWebView];

}

@end
