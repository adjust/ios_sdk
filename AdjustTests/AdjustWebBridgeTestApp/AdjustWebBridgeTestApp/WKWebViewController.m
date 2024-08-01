//
//  WKWebViewController.m
//  AdjustWebBridgeTestApp
//
//  Created by Pedro Silva (@nonelse) on 6th August 2018.
//  Copyright © 2018-Present Adjust GmbH. All rights reserved.
//

#import "WKWebViewController.h"
#import "TestLibraryBridge.h"

#import <WebKit/WebKit.h>
#import <AdjustBridge/AdjustBridge.h>

@interface WKWebViewController ()

@property AdjustBridge *adjustBridge;
@property TestLibraryBridge *testLibraryBridge;

@end

@implementation WKWebViewController

#pragma mark - View Controller Life cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {

    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];

    self.adjustBridge = [[AdjustBridge alloc] init];
    [self.adjustBridge loadWKWebViewBridge:webView];

    if (@available(iOS 16.4, *)) {
        [webView setInspectable:YES];
    } else {
        // Fallback on earlier versions
    }

    self.testLibraryBridge = [[TestLibraryBridge alloc]
                              initWithAdjustBridge:self.adjustBridge];

    NSString *htmlPath = [[NSBundle mainBundle]
                          pathForResource:@"AdjustTestApp-WebView" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath
                                                  encoding:NSUTF8StringEncoding error:nil];

    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

@end

