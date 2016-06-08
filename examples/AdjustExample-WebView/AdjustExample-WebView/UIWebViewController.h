//
//  ViewController.h
//  AdjustExample-WebView
//
//  Created by Uglješa Erceg on 31/05/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdjustWebBridge.h"

@interface UIWebViewController : UINavigationController <UIWebViewDelegate>

@property AdjustWebBridge *adjustBridge;

@end

