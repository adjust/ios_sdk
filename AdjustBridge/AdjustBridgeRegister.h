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
- (void)augmentHybridWebView:(NSString *)fbAppId;
+ (NSString *)AdjustBridge_js;

@end
