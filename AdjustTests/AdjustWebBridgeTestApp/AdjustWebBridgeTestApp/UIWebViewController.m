//
//  UIWebViewController.m
//  AdjustWebBridgeTestApp
//
//  Created by Pedro Silva (@nonelse) on 6th August 2018.
//  Copyright © 2018 Adjust GmbH. All rights reserved.
//

#import "AdjustBridge.h"
#import "TestLibraryBridge.h"
#import "UIWebViewController.h"
#import "WebViewJavascriptBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface UIWebViewController ()

@property JSContext *jsContext;
@property AdjustBridge *adjustBridge;
@property WebViewJavascriptBridge *bridge;
@property TestLibraryBridge *testLibraryBridge;

@end

@implementation UIWebViewController

- (void)viewWillAppear:(BOOL)animated {
    if (_bridge) {
        return;
    }

    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];

    self.adjustBridge = [[AdjustBridge alloc] init];
    [self.adjustBridge loadUIWebViewBridge:webView webViewDelegate:self];

    _jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    _jsContext[@"console"][@"log"] = ^(JSValue *msg) {
        NSLog(@"JavaScript %@ log message: %@", [JSContext currentContext], msg);
    };

    self.testLibraryBridge = [[TestLibraryBridge alloc] initWithAdjustBridgeRegister:[self.adjustBridge bridgeRegister]];

    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"AdjustTestApp-WebView" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

@end
