//
//  WKWebViewController.h
//  AdjustExample-WebView
//
//  Created by Uglješa Erceg (@uerceg) on 23rd August 2018.
//  Copyright © 2018-Present Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "AdjustBridge.h"

@interface WKWebViewController : UIViewController

@property AdjustBridge *adjustBridge;
@property JSContext *jsContext;

@end
