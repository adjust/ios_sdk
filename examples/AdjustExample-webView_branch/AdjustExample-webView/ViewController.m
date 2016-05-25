//
//  ViewController.m
//  AdjustExample-webView
//
//  Created by Pedro Filipe on 16/03/16.
//  Copyright © 2016 adjust. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];

    //[AdjustBridge loadBridge:self webView:webView];

    [self loadExamplePage:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadExamplePage:(UIWebView*)webView
{
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"AdjustExampleWebView" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

@end
