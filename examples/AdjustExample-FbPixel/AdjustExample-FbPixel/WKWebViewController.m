//
//  WKWebViewController.m
//  AdjustExample-WebView
//
//  Created by Uglješa Erceg (@uerceg) on 23rd August 2018.
//  Copyright © 2018-Present Adjust GmbH. All rights reserved.
//

#import "WKWebViewController.h"

@interface WKWebViewController ()<WKNavigationDelegate>

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
