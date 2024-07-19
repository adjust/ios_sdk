//
//  WKWebViewController.h
//  AdjustExample-WebView
//
//  Created by Aditi Agrawal on 19/07/24.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "AdjustBridge.h"

@interface WKWebViewController : UINavigationController<WKNavigationDelegate, WKUIDelegate>

@property AdjustBridge *adjustBridge;

@end
