//
//  AdjustBridge.h
//  Adjust
//
//  Created by Pedro Filipe on 27/04/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <Foundation/Foundation.h>

#import "WKWebViewJavascriptBridge.h"
#import "WebViewJavascriptBridge.h"
#import "AdjustBridgeRegister.h"

@interface AdjustBridge : NSObject

@property (nonatomic, strong, readonly) id<AdjustBridgeRegister> bridgeRegister;

- (void)loadUIWebViewBridge:(WVJB_WEBVIEW_TYPE *)webView;
- (void)loadWKWebViewBridge:(WKWebView *)wkWebView;
- (void)loadUIWebViewBridge:(WVJB_WEBVIEW_TYPE *)webView webViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *)webViewDelegate;
- (void)loadWKWebViewBridge:(WKWebView *)wkWebView wkWebViewDelegate:(id<WKNavigationDelegate>)wkWebViewDelegate;

@end
