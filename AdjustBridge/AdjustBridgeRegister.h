//
//  AdjustWebViewJSBridge.h
//  Adjust
//
//  Created by Pedro Filipe on 10/06/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"

@protocol AdjustBridgeRegister <NSObject>

- (void)callHandler:(NSString *)handlerName data:(id)data;
- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler;

@end

@interface AdjustUIBridgeRegister : NSObject<AdjustBridgeRegister>

+ (id<AdjustBridgeRegister>)bridgeRegisterWithUIWebView:(WVJB_WEBVIEW_TYPE *)webView;
- (void)setWebViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *)webViewDelegate;

@end

@interface AdjustWKBridgeRegister : NSObject<AdjustBridgeRegister>

+ (id<AdjustBridgeRegister>)bridgeRegisterWithWKWebView:(WKWebView *)webView;
- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate;

@end
