//
//  AdjustBridge.h
//  Adjust
//
//  Created by Aditi Agrawal on 14/05/24.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface AdjustBridge : NSObject

- (void)augmentHybridWKWebView:(WKWebView *_Nonnull)webView;

@property (strong, nonatomic) WKWebView * _Nonnull webView;

@end
