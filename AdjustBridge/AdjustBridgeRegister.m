//
//  AdjustBridgeRegister.m
//  Adjust SDK
//
//  Created by Pedro Filipe (@nonelse) on 10th June 2016.
//  Copyright © 2016-2018 Adjust GmbH. All rights reserved.
//

#import "AdjustBridgeRegister.h"

static NSString * const kHandlerPrefix = @"adjust_";

@interface AdjustBridgeRegister()

@property (nonatomic, strong) WebViewJavascriptBridge *wvjb;
@property BOOL isToAugmentHybridWebView;

@end

@implementation AdjustBridgeRegister

- (id)initWithWebView:(id)webView {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.wvjb = [WebViewJavascriptBridge bridgeForWebView:webView];
    self.isToAugmentHybridWebView = NO;
    return self;
}

- (void)setWebViewDelegate:(id)webViewDelegate {
    [self.wvjb setWebViewDelegate:webViewDelegate];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self.wvjb callHandler:handlerName data:data];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    [self.wvjb registerHandler:handlerName handler:handler];
}


@end
/*

@interface AdjustUIBridgeRegister()

@property (nonatomic, strong) WebViewJavascriptBridge *uiBridge;

@end

@implementation AdjustUIBridgeRegister

+ (id<AdjustBridgeRegister>)bridgeRegisterWithUIWebView:(WVJB_WEBVIEW_TYPE *)uiWebView {
    return [[AdjustUIBridgeRegister alloc] initWithUIWebView:uiWebView];
}

- (id)initWithUIWebView:(WVJB_WEBVIEW_TYPE *)uiWebView {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.uiBridge = [WebViewJavascriptBridge bridgeForWebView:uiWebView];
    return self;
}

- (void)setWebViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *)webViewDelegate {
    [self.uiBridge setWebViewDelegate:webViewDelegate];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    if ([handlerName hasPrefix:kHandlerPrefix] == NO) {
        return;
    }
    [self.uiBridge registerHandler:handlerName handler:handler];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    if ([handlerName hasPrefix:kHandlerPrefix] == NO) {
        return;
    }
    [self.uiBridge callHandler:handlerName data:data];
}

@end

@interface AdjustWKBridgeRegister()

@property (nonatomic, strong) WebViewJavascriptBridge *wkBridge;

@end

@implementation AdjustWKBridgeRegister

+ (id<AdjustBridgeRegister>)bridgeRegisterWithWKWebView:(WKWebView *)wkWebView {
    return [[AdjustWKBridgeRegister alloc] initWithWKWebView:wkWebView];
}

- (id)initWithWKWebView:(WKWebView *)wkWebView {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.wkBridge = [WebViewJavascriptBridge bridgeForWebView:wkWebView];
    return self;
}

- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate {
    [self.wkBridge setWebViewDelegate:webViewDelegate];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    if ([handlerName hasPrefix:kHandlerPrefix] == NO) {
        return;
    }
    [self.wkBridge registerHandler:handlerName handler:handler];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    if ([handlerName hasPrefix:kHandlerPrefix] == NO) {
        return;
    }
    [self.wkBridge callHandler:handlerName data:data];
}

@end
*/
