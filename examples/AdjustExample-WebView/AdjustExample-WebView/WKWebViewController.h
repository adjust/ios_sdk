//
//  WKWebViewController.h
//  AdjustExample-WebView
//
//  Created by Uglješa Erceg (@uerceg) on 31st May 2016.
//  Copyright © 2016-Present Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "AdjustBridge.h"

@interface WKWebViewController : UINavigationController<WKNavigationDelegate, WKUIDelegate>

@property AdjustBridge *adjustBridge;

@end
