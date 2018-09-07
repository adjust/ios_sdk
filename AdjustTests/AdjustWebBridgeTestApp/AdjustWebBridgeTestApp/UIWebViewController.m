//
//  UIWebViewController.m
//  AdjustWebBridgeTestApp
//
//  Created by Pedro on 06.08.18.
//  Copyright © 2018 adjust. All rights reserved.
//
#import <JavaScriptCore/JavaScriptCore.h>
#import "UIWebViewController.h"
#import "WebViewJavascriptBridge.h"
#import "AdjustBridge.h"
#import "TestLibraryBridge.h"

@interface UIWebViewController ()
@property WebViewJavascriptBridge* bridge;
@property AdjustBridge *adjustBridge;
@property JSContext *jsContext;
@property TestLibraryBridge * testLibraryBridge;

@end

@implementation UIWebViewController

- (void)viewWillAppear:(BOOL)animated {
    if (_bridge) { return; }

    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];

    self.adjustBridge = [[AdjustBridge alloc] init];
    [self.adjustBridge loadUIWebViewBridge:webView webViewDelegate:self];

    _jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    _jsContext[@"console"][@"log"] = ^(JSValue * msg) {
        NSLog(@"JavaScript %@ log message: %@", [JSContext currentContext], msg);
    };

    self.testLibraryBridge = [[TestLibraryBridge alloc] initWithAdjustBridgeRegister:[self.adjustBridge bridgeRegister]];

    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"AdjustTestApp-WebView" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

@end
