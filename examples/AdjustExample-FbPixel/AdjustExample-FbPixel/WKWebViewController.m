//
//  WKWebViewController.m
//  AdjustExample-WebView
//
//  Created by Uglješa Erceg (@uerceg) on 23rd August 2018.
//  Copyright © 2018-Present Adjust GmbH. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import <AdjustBridge/AdjustBridge.h>

@interface WKWebViewController ()<WKNavigationDelegate, WKUIDelegate>

@property AdjustBridge *adjustBridge;

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
    wkWebView.UIDelegate = self;
    _adjustBridge = [[AdjustBridge alloc] init];
    [_adjustBridge augmentHybridWebView];
    [_adjustBridge loadWKWebViewBridge:wkWebView];

    if (@available(iOS 16.4, *)) {
        [wkWebView setInspectable:YES];
    } else {
        // Fallback on earlier versions
    }

    NSString *path = [[NSBundle mainBundle] 
                      pathForResource:@"AdjustExample-FbPixel" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [wkWebView loadRequest:request];
    [self.view addSubview:wkWebView];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
   initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

@end
