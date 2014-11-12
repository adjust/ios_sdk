//
//  AdjustBridge.m
//  Adjust
//
//  Created by Pedro Filipe on 19/05/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AdjustBridge.h"
#import "WebViewJavascriptBridge.h"
#import "ADJEvent.h"
#import "Adjust.h"

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

        // TODO, test
        ADJEvent * event= [data objectForKey:@"event"];
        /*
        NSString* eventToken = [data objectForKey:@"eventToken"];
        NSDictionary* parameters = [data objectForKey:@"parameters"];
        NSNumber* revenue = [data objectForKey:@"revenue"];
        NSString* currency = [data objectForKey:@"currency"];

        AIEvent* event = [[AIEvent alloc] initWithEventToken:eventToken];

        if (parameters != nil) {
            for (NSString* key in parameters) {
                NSString* value = [parameters objectForKey:key];
                [event addCallbackParameter:key andValue:value];
            }
        }

        if (revenue != nil) {
            [event setRevenue:[revenue doubleValue] currency:currency];
        }
         */
        [Adjust trackEvent:event];
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
}
@end
