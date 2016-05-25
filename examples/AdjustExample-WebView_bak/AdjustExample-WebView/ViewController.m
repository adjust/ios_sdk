//
//  ViewController.m
//  AdjustExample-WebView
//
//  Created by Pedro Filipe on 26/04/16.
//  Copyright © 2016 adjust. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    NSString *localURL = [NSBundle pathForResource:@"index" ofType:@"html" inDirectory:nil];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:localURL]];
    [self.mainWebView loadRequest:urlRequest];
     */
    [self loadExamplePage:self.mainWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadExamplePage:(UIWebView*)webView
{
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"AdjustExample" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}


@end
