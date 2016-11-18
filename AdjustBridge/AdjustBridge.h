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

@interface AdjustBridge : NSObject

- (void)loadUIWebViewBridge:(WVJB_WEBVIEW_TYPE *)webView;
- (void)loadWKWebViewBridge:(WKWebView *)wkWebView;
- (void)loadUIWebViewBridge:(WVJB_WEBVIEW_TYPE *)webView webViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *)webViewDelegate;
- (void)loadWKWebViewBridge:(WKWebView *)wkWebView wkWebViewDelegate:(id<WKNavigationDelegate>)wkWebViewDelegate;

- (void)sendDeeplinkToWebView:(NSURL *)deeplink;

@end
