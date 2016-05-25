//
//  ViewController.h
//  AdjustExample-WebView
//
//  Created by Pedro Filipe on 26/04/16.
//  Copyright © 2016 adjust. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *mainWebView;

@end

