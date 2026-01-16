//
//  ADJLinkResolution.m
//  Adjust
//
//  Created by Pedro Silva (@nonelse) on 26th April 2021.
//  Copyright © 2021-Present Adjust GmbH. All rights reserved.
//

#import "ADJLinkResolution.h"
#import "ADJUtil.h"
#import <objc/runtime.h>

static NSUInteger kMaxRecursions = 10;
static char kRedirectCountKey;

// forward declaration for private methods
@interface ADJLinkResolution (Private)
+ (BOOL)isTerminalUrlWithHost:(nullable NSString *)urlHost;
+ (nullable NSURL *)convertUrlToHttps:(nullable NSURL *)url;
@end

// delegate to handle redirects
@interface ADJLinkResolutionDelegate : NSObject<NSURLSessionTaskDelegate>
+ (nonnull ADJLinkResolutionDelegate *)sharedInstance;
@end

@implementation ADJLinkResolutionDelegate

+ (nonnull ADJLinkResolutionDelegate *)sharedInstance {
    static ADJLinkResolutionDelegate *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                     willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                                     newRequest:(NSURLRequest *)request
                              completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    // track redirect count using associated object (thread safe)
    NSNumber *count = objc_getAssociatedObject(task, &kRedirectCountKey);
    NSUInteger redirectCount = count ? [count unsignedIntegerValue] + 1 : 1;
    objc_setAssociatedObject(task, &kRedirectCountKey, @(redirectCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // stop if exceeded max redirects
    if (redirectCount > kMaxRecursions) {
        completionHandler(nil);
        return;
    }

    // stop at terminal domains
    if ([ADJLinkResolution isTerminalUrlWithHost:response.URL.host]) {
        completionHandler(nil);
        return;
    }

    // convert HTTP to HTTPS in redirect URLs
    NSURL *convertedUrl = [ADJLinkResolution convertUrlToHttps:request.URL];
    if (convertedUrl && ![request.URL isEqual:convertedUrl]) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        mutableRequest.URL = convertedUrl;
        completionHandler([mutableRequest copy]);
    } else {
        completionHandler(request);
    }
}

@end

@implementation ADJLinkResolution

+ (void)resolveLinkWithUrl:(nonnull NSURL *)url
     resolveUrlSuffixArray:(nullable NSArray<NSString *> *)resolveUrlSuffixArray
                  callback:(nonnull void (^)(NSURL *_Nullable resolvedLink))callback {
    // ignore if callback is not provided
    if (!callback) {
        return;
    }

    // early returns for invalid URLs
    if (!url || !url.host || url.host.length == 0) {
        [ADJUtil launchInMainThread:^{
            callback(url);
        }];
        return;
    }

    // only resolve when suffix array is provided and matches
    if (!resolveUrlSuffixArray || ![self urlMatchesSuffixWithHost:url.host suffixArray:resolveUrlSuffixArray]) {
        [ADJUtil launchInMainThread:^{
            callback(url);
        }];
        return;
    }

    // create/retrieve shared session
    static NSURLSession *sharedSession = nil;
    static dispatch_once_t sessionOnceToken;
    dispatch_once(&sessionOnceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        config.timeoutIntervalForRequest = 3.0;
        config.timeoutIntervalForResource = 8.0;
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        config.URLCache = nil;

        sharedSession = [NSURLSession sessionWithConfiguration:config
                                                      delegate:[ADJLinkResolutionDelegate sharedInstance]
                                                 delegateQueue:nil];
    });
    
    // convert HTTP to HTTPS for initial URL
    NSURL *httpsUrl = [self convertUrlToHttps:url];

    // make GET request; NSURLSession automatically follows redirects
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:httpsUrl];
    request.HTTPMethod = @"GET";

    __block NSURLSessionDataTask *task =
    [sharedSession dataTaskWithRequest:request
                     completionHandler:^(NSData * _Nullable data,
                                         NSURLResponse * _Nullable response,
                                         NSError * _Nullable error) {
        NSURL *finalUrl = response.URL ?: (error ? task.currentRequest.URL : httpsUrl) ?: httpsUrl;
        [ADJUtil launchInMainThread:^{
            callback(finalUrl);
        }];
    }];
    [task resume];
}

+ (nullable NSURL *)convertUrlToHttps:(nullable NSURL *)url {
    if (!url || ![url.absoluteString hasPrefix:@"http:"]) {
        return url;
    }
    return [NSURL URLWithString:[url.absoluteString stringByReplacingOccurrencesOfString:@"http:"
                                                                              withString:@"https:"
                                                                                 options:0
                                                                                   range:NSMakeRange(0, 5)]];
}

+ (BOOL)isTerminalUrlWithHost:(nullable NSString *)urlHost {
    if (!urlHost) {
        return NO;
    }

    NSArray<NSString *> *terminalSuffixes =
    @[@"adjust.com", @"adj.st", @"go.link", @"adjust.cn", @"adjust.net.in", @"adjust.world", @"adjust.io"];
    for (NSString *suffix in terminalSuffixes) {
        if ([urlHost hasSuffix:suffix]) {
            return YES;
        }
    }

    return NO;
}

+ (BOOL)urlMatchesSuffixWithHost:(nullable NSString *)urlHost
                     suffixArray:(nullable NSArray<NSString *> *)suffixArray {
    if (!urlHost || !suffixArray) {
        return NO;
    }

    for (NSString *suffix in suffixArray) {
        if ([urlHost hasSuffix:suffix]) {
            return YES;
        }
    }

    return NO;
}

@end
