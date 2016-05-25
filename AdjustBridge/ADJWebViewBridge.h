//
//  ADJWebViewBridge.h
//  Adjust
//
//  Created by Pedro Filipe on 27/04/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"

@interface ADJWebViewBridge : NSObject

- (void)loadUIWebViewBridge:(UIWebView *) webView;

- (void)loadWKWebViewBridge:(WKWebView *) webView;

@end
