//
//  ADJWebViewBridge.m
//  Adjust
//
//  Created by Pedro Filipe on 27/04/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "ADJWebViewBridge.h"
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "Adjust.h"
#import "ADJAdjustFactory.h"
#import "ADJLogger.h"

static NSString   * const kAdjustJsPrefix          = @"adjust_";

@interface ADJWebViewBridge()

@property WebViewJavascriptBridge* uiBridge;
@property WKWebViewJavascriptBridge* wkBridge;

@end

@implementation ADJWebViewBridge

- (id) init {
    self = [super init];
    return self;
}

- (void)loadUIWebViewBridge:(UIWebView *) uiWebView {
    if (self.uiBridge) {
        return;
    }

    [WebViewJavascriptBridge enableLogging];

    self.uiBridge = [WebViewJavascriptBridge bridgeForWebView:uiWebView];

    [self.uiBridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];

    [self.uiBridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
}

- (void)loadWKWebViewBridge:(WKWebView *) wkWebView {
    id<ADJLogger> logger = [ADJAdjustFactory logger];

    if (self.wkBridge) {
        [logger warn:@"WKWebViewBridge already loaded"];
        return;
    }

    [WKWebViewJavascriptBridge enableLogging];

    self.wkBridge = [WKWebViewJavascriptBridge bridgeForWebView:wkWebView];

    [self.wkBridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];

    [self.wkBridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];

    [self.wkBridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];

    [self.wkBridge registerHandler:[NSString stringWithFormat:@"%@trackEvent", kAdjustJsPrefix]  handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString* eventToken = [data objectForKey:@"eventToken"];
        ADJEvent* event = [ADJEvent eventWithEventToken:eventToken];
        [Adjust trackEvent:event];
    }];

,,        }
        if (result == nil) {
            [logger error:@"Result of detect AdjustBridge is nil"];
            return;
        }

        [logger debug:@"Result to parse: %@", result];

        if ([result intValue] != 1) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *filePath = [bundle pathForResource:@"ADJWebViewBridge.js" ofType:@"txt"];
            NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

            [wkWebView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error)
            {
                if (error != nil) {
                    [logger error:@"Failed to load AdjustBridge (%@)", error.localizedDescription];
                    return;
                }

                [logger verbose:@"AdjustBridge JS loaded: %@", result];
            }];
        }
    }];
}

@end
