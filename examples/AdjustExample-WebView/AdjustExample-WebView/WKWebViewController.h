//
//  WKWebViewController.h
//  AdjustExample-WebView
//
//  Created by Aditi Agrawal on 29/07/24.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <AdjustBridge/AdjustBridge.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewController : UINavigationController<WKNavigationDelegate, WKUIDelegate>

@property AdjustBridge *adjustBridge;

@end

NS_ASSUME_NONNULL_END
