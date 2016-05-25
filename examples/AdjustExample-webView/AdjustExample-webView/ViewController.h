//
//  ViewController.h
//  AdjustExample-webView
//
//  Created by Pedro Filipe on 27/04/16.
//  Copyright © 2016 adjust. All rights reserved.
//

// Needed for UIViewController, UIWebViewDelegate, and UIView
#import <UIKit/UIKit.h>
// Needed for WKNavigationDelegate and WKUIDelegate
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController <UIWebViewDelegate, WKNavigationDelegate>


@end

