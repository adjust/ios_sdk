//
//  AdjustBridge.h
//  Adjust
//
//  Created by Pedro Filipe on 19/05/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Adjust.h"
#import <UIKit/UIKit.h>

@interface AdjustBridge : NSObject<AdjustDelegate>

- (void)adjustFinishedTrackingWithResponse:(AIResponseData *)responseData;

+ (void)loadBridge:(NSObject<UIWebViewDelegate> *) webViewDelegate
            webView:(UIWebView *) webView;

@end
