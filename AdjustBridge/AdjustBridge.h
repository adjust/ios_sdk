//
//  AdjustBridge.h
//  Adjust
//
//  Created by Pedro Filipe (@nonelse) on 27th April 2016.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface AdjustBridge : NSObject

- (void)loadWKWebViewBridge:(WKWebView *_Nonnull)wkWebView;
- (void)augmentHybridWebView;

@property (strong, nonatomic) WKWebView * _Nonnull wkWebView;

@end
