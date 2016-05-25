//
//  ViewController.m
//  AdjustExample-webView
//
//  Created by Pedro Filipe on 27/04/16.
//  Copyright © 2016 adjust. All rights reserved.
//

#import "ViewController.h"
#import "WKWebViewJavascriptBridge.h"
#import "WebViewJavascriptBridge.h"
#import "ADJWebViewBridge.h"

@interface ViewController ()

@property WKWebViewJavascriptBridge* wkBridge;
@property WebViewJavascriptBridge* uiBridge;
@property ADJWebViewBridge * adjustBridge;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    if (NSClassFromString(@"WKWebView")) {
        [self loadWKWebView];
    } else {
        [self loadUIWebView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadWKWebView {
    WKWebView * wkWebView = [[WKWebView alloc] initWithFrame: [[self view] bounds]];
    [[self view] addSubview: wkWebView];

    _adjustBridge = [[ADJWebViewBridge alloc] init];
    [_adjustBridge loadWKWebViewBridge:wkWebView];
/*
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];

    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callWkHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:wkWebView];
    callbackButton.frame = CGRectMake(10, 400, 100, 35);
    callbackButton.titleLabel.font = font;

    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"Reload webview" forState:UIControlStateNormal];
    [reloadButton addTarget:wkWebView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:wkWebView];
    reloadButton.frame = CGRectMake(110, 400, 100, 35);
    reloadButton.titleLabel.font = font;
*/
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"AdjustExample-webView" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [wkWebView loadHTMLString:appHtml baseURL:baseURL];
}

- (void)callWkHandler:(id)sender {
    //id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    //[_wkBridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
    //    NSLog(@"testJavascriptHandler responded: %@", response);
    //}];
}

- (void)loadUIWebView {
    UIWebView * uiWebView = [[UIWebView alloc] initWithFrame: [[self view] bounds]];
    [[self view] addSubview: uiWebView];

    ADJWebViewBridge * adjustBridge = [[ADJWebViewBridge alloc] init];
    [adjustBridge loadUIWebViewBridge:uiWebView];
/*
    [WebViewJavascriptBridge enableLogging];

    _uiBridge = [WebViewJavascriptBridge bridgeForWebView:uiWebView];

    [_uiBridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];

    [_uiBridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
*/
/*
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];

    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callUiHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:uiWebView];
    callbackButton.frame = CGRectMake(10, 400, 100, 35);
    callbackButton.titleLabel.font = font;

    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"Reload webview" forState:UIControlStateNormal];
    [reloadButton addTarget:uiWebView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:uiWebView];
    reloadButton.frame = CGRectMake(110, 400, 100, 35);
    reloadButton.titleLabel.font = font;
*/
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"AdjustExample-webView" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [uiWebView loadHTMLString:appHtml baseURL:baseURL];
}

- (void)callUiHandler:(id)sender {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_uiBridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
}

@end
