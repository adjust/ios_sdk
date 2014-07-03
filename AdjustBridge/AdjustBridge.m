//
//  AdjustBridge.m
//  Adjust
//
//  Created by Pedro Filipe on 19/05/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AdjustBridge.h"
#import "WebViewJavascriptBridge.h"

static NSString   * const kAdjustJsPrefix          = @"adjust_";

static WebViewJavascriptBridge* _AdjustBridge = nil;
static id<AdjustDelegate> adjustBridgeInstance = nil;

@implementation AdjustBridge

- (id) init {
    self = [super init];
    return self;
}

+ (void) loadBridge:(NSObject<UIWebViewDelegate> *) webViewDelegate
            webView:(UIWebView *) webView {
    if (_AdjustBridge) { return; }

    _AdjustBridge = [WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:webViewDelegate handler:^(id data, WVJBResponseCallback responseCallback) {
    }];

    [_AdjustBridge registerHandler:[NSString stringWithFormat:@"%@trackEvent", kAdjustJsPrefix] handler:^(id data, WVJBResponseCallback responseCallback) {

        NSString* eventToken = [data objectForKey:@"eventToken"];
        NSDictionary* parameters = [data objectForKey:@"parameters"];

        if (parameters != nil) {
            [Adjust trackEvent:eventToken withParameters:parameters];
        }  else {
            [Adjust trackEvent:eventToken];
        }
    }];

    [_AdjustBridge registerHandler:[NSString stringWithFormat:@"%@trackRevenue", kAdjustJsPrefix] handler:^(id data, WVJBResponseCallback responseCallback) {

        NSString* eventToken = [data objectForKey:@"eventToken"];
        NSDictionary* parameters = [data objectForKey:@"parameters"];
        double amountInCents = [[data objectForKey:@"amountInCents"] doubleValue];

        if (parameters != nil) {
            [Adjust trackRevenue:amountInCents forEvent:eventToken withParameters:parameters];
        } else if (eventToken != nil) {
            [Adjust trackRevenue:amountInCents forEvent:eventToken];
        } else {
            [Adjust trackRevenue:amountInCents];
        }
    }];

    [_AdjustBridge registerHandler:[NSString stringWithFormat:@"%@setResponseDelegate", kAdjustJsPrefix] handler:^(id data, WVJBResponseCallback responseCallback) {

        adjustBridgeInstance = [[AdjustBridge alloc] init];
        [Adjust setDelegate:adjustBridgeInstance];
    }];

    [_AdjustBridge registerHandler:[NSString stringWithFormat:@"%@setEnabled", kAdjustJsPrefix] handler:^(id data, WVJBResponseCallback responseCallback) {

        BOOL enabled = [[data objectForKey:@"enabled"] boolValue];
        [Adjust setEnabled:enabled];
    }];

    [_AdjustBridge registerHandler:[NSString stringWithFormat:@"%@isEnabled", kAdjustJsPrefix] handler:^(id data, WVJBResponseCallback responseCallback) {

        BOOL isEnabled = [Adjust isEnabled];

        responseCallback([NSNumber numberWithBool:isEnabled]);
    }];

    [_AdjustBridge registerHandler:[NSString stringWithFormat:@"%@openUrl", kAdjustJsPrefix] handler:^(id data, WVJBResponseCallback responseCallback) {

        NSURL* url = [[NSURL alloc] initWithString:[data objectForKey:@"url"]];
        [Adjust appWillOpenUrl:url];
    }];

    if (![[webView stringByEvaluatingJavaScriptFromString:@"typeof AdjustBridge == 'object'"] isEqualToString:@"true"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *filePath = [bundle pathForResource:@"AdjustBridge.js" ofType:@"txt"];
        NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [webView stringByEvaluatingJavaScriptFromString:js];
    }

    [Adjust setSdkPrefix:@"bridge"];
}

- (void)adjustFinishedTrackingWithResponse:(AIResponseData *)responseData {
    NSMutableDictionary* dicResponseData = (NSMutableDictionary*) [responseData dictionary];

    [dicResponseData removeObjectForKey:@"success"];
    [dicResponseData setObject:[NSNumber numberWithBool:responseData.success] forKey:@"success"];

    [dicResponseData removeObjectForKey:@"willRetry"];
    [dicResponseData setObject:[NSNumber numberWithBool:responseData.willRetry] forKey:@"willRetry"];

    [_AdjustBridge callHandler:@"responseDelegate" data:dicResponseData responseCallback:^(id response) {}];
}
@end
