//
//  WKWebViewController.m
//  AdjustExample-WebView
//
//  Created by Uglješa Erceg (@uerceg) on 31st May 2016.
//  Copyright © 2016-Present Adjust GmbH. All rights reserved.
//

#import "WKWebViewController.h"

@interface WKWebViewController ()

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadWKWebView];
}

- (void)loadWKWebView {
    WKWebView *webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    [self.view addSubview:webView];

    _adjustBridge = [[AdjustBridge alloc] init];
    [_adjustBridge loadWKWebViewBridge:webView];

    if (@available(iOS 16.4, *)) {
        [webView setInspectable: YES];
    } else {
        // Fallback on earlier versions
    }

    // load remote web page
    //    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://adjustweb.neocities.org"]];
    //    [webView loadRequest:request];

    // alternative to load web page from local HTML resource
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"AdjustExample-WebView" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
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

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


