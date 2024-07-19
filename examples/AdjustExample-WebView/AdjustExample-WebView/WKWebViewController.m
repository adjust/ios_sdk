//
//  WKWebViewController.m
//  AdjustExample-WebView
//
//  Created by Aditi Agrawal on 19/07/24.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
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
    WKWebView *webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    [self.view addSubview:webView];

    _adjustBridge = [[AdjustBridge alloc] init];
    [_adjustBridge augmentHybridWKWebView:webView];

    // load remote web page
    //    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://adjustweb.neocities.org"]];
    //    [webView loadRequest:request];

    // alternative to load web page from local HTML resource
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"AdjustExample-WebView" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];

    if (@available(iOS 16.4, *)) {
        [webView setInspectable:YES];
    } else {
        // Fallback on earlier versions
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
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


