//
//  AdjustWebViewJSBridge.h
//  Adjust SDK
//
//  Created by Pedro Filipe (@nonelse) on 10th June 2016.
//  Copyright © 2016-2018 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"

@interface AdjustBridgeRegister : NSObject

- (id)initWithWebView:(id)webView;
- (void)setWebViewDelegate:(id)webViewDelegate;

- (void)callHandler:(NSString *)handlerName data:(id)data;
- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler;

@end
/*
@protocol AdjustBridgeRegister <NSObject>

- (void)callHandler:(NSString *)handlerName data:(id)data;
- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler;
- (void)augmentHybridWebView;
+ (NSString *)AdjustBridge_js;

@end

@interface AdjustUIBridgeRegister : NSObject<AdjustBridgeRegister>

+ (id<AdjustBridgeRegister>)bridgeRegisterWithUIWebView:(WVJB_WEBVIEW_TYPE *)webView;
- (void)setWebViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *)webViewDelegate;

@end

@interface AdjustWKBridgeRegister : NSObject<AdjustBridgeRegister>

+ (id<AdjustBridgeRegister>)bridgeRegisterWithWKWebView:(WKWebView *)webView;
- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate;

@end
*/
