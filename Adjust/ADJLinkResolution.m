//
//  ADJLinkResolution.m
//  Adjust
//
//  Created by Pedro Silva (@nonelse) on 26th April 2021.
//  Copyright © 2021-Present Adjust GmbH. All rights reserved.
//

#import "ADJLinkResolution.h"

static NSUInteger kMaxRecursions = 10;

@interface ADJLinkResolution (Private)

+ (BOOL)isTerminalUrlWithHost:(nullable NSString *)urlHost;

@end

@interface ADJLinkResolutionDelegate : NSObject<NSURLSessionTaskDelegate>

+ (nonnull ADJLinkResolutionDelegate *)sharedInstance;

+ (nullable NSURL *)convertUrlToHttps:(nullable NSURL *)url;

+ (NSURLRequest *)replaceUrlWithRequest:(NSURLRequest *)request
                           urlToReplace:(nonnull NSURL *)urlToReplace;

@end

@implementation ADJLinkResolutionDelegate

- (nonnull instancetype)init {
    self = [super init];
    return self;
}

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
                              completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    // if we're already at a terminal host (adjust.com / adj.st / go.link),
    // stop auto-following to preserve the terminal URL (avoid jumping to App Store links)
    if ([ADJLinkResolution isTerminalUrlWithHost:response.URL.host]) {
        completionHandler(nil);
        return;
    }

    NSURL *_Nullable convertedUrl = [ADJLinkResolutionDelegate convertUrlToHttps:request.URL];

    if (request.URL != nil && convertedUrl != nil && ![request.URL isEqual:convertedUrl]) {
        completionHandler([ADJLinkResolutionDelegate replaceUrlWithRequest:request
                                                              urlToReplace:convertedUrl]);
    } else {
        completionHandler(request);
    }
}

+ (nullable NSURL *)convertUrlToHttps:(nullable NSURL *)url {
    if (url == nil) {
        return nil;
    }
    if (![url.absoluteString hasPrefix:@"http:"]) {
        return url;
    }

    NSString *_Nonnull urlStringWithoutPrefix = [url.absoluteString substringFromIndex:5];
    return [NSURL URLWithString:[NSString stringWithFormat:@"https:%@", urlStringWithoutPrefix]];
}

+ (NSURLRequest *)replaceUrlWithRequest:(NSURLRequest *)request
                           urlToReplace:(nonnull NSURL *)urlToReplace {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setURL:urlToReplace];
    return [mutableRequest copy];
}

@end

@implementation ADJLinkResolution

+ (void)resolveLinkWithUrl:(nonnull NSURL *)url
     resolveUrlSuffixArray:(nullable NSArray<NSString *> *)resolveUrlSuffixArray
                  callback:(nonnull void (^)(NSURL *_Nullable resolvedLink))callback {
    if (callback == nil) {
        return;
    }
    if (url == nil) {
        callback(nil);
        return;
    }

    // if suffix array is provided and URL doesn't match, return URL unchanged
    if (resolveUrlSuffixArray != nil &&
        ![ADJLinkResolution urlMatchesSuffixWithHost:url.host
                                         suffixArray:resolveUrlSuffixArray]) {
        callback(url);
        return;
    }

    ADJLinkResolutionDelegate *_Nonnull linkResolutionDelegate = [ADJLinkResolutionDelegate sharedInstance];

    // reuse shared session for better performance
    static NSURLSession *sharedSession = nil;
    static dispatch_once_t sessionOnceToken;
    dispatch_once(&sessionOnceToken, ^{
        sharedSession =
        [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration
                                      delegate:linkResolutionDelegate
                                 delegateQueue:nil];
    });

    NSURL *_Nullable httpsUrl = [ADJLinkResolutionDelegate convertUrlToHttps:url];
    NSURLSessionDataTask *task =
        [sharedSession
            dataTaskWithURL:httpsUrl
            completionHandler:
                ^(NSData * _Nullable data,
                  NSURLResponse * _Nullable response,
                  NSError * _Nullable error) {
                // bootstrap the recursion of resolving the link
                [ADJLinkResolution resolveLinkWithResponseUrl:response != nil ? response.URL : nil
                                                  previousUrl:httpsUrl
                                              recursionNumber:0
                                                      session:sharedSession
                                                     callback:callback];
            }];
    [task resume];
}

+ (void)resolveLinkWithResponseUrl:(nullable NSURL *)responseUrl
                       previousUrl:(nullable NSURL *)previousUrl
                   recursionNumber:(NSUInteger)recursionNumber
                           session:(nonnull NSURLSession *)session
                          callback:(nonnull void (^)(NSURL *_Nullable resolvedLink))callback {
    // return (possible nil) previous url when the current one does not exist
    if (responseUrl == nil) {
        callback(previousUrl);
        return;
    }
    // stop recursion when URL stops changing (prevents infinite loops)
    if (previousUrl != nil && [responseUrl isEqual:previousUrl]) {
        callback(responseUrl);
        return;
    }
    // return found url with expected host (Adjust terminal domains)
    // these are domains where we stop to avoid redirecting to App Store
    if ([ADJLinkResolution isTerminalUrlWithHost:responseUrl.host]) {
        callback(responseUrl);
        return;
    }
    // return current url when it reached the max number of recursive tries
    if (recursionNumber >= kMaxRecursions) {
        callback(responseUrl);
        return;
    }

    // when found a non expected url host, use it to recursively resolve the link
    NSURLSessionDataTask *task =
        [session
            dataTaskWithURL:responseUrl
            completionHandler:
                ^(NSData * _Nullable data,
                  NSURLResponse * _Nullable response,
                  NSError * _Nullable error) {
            [ADJLinkResolution resolveLinkWithResponseUrl:response != nil ? response.URL : nil
                                              previousUrl:responseUrl
                                          recursionNumber:(recursionNumber + 1)
                                                  session:session
                                                 callback:callback];
        }];
    [task resume];
}

+ (BOOL)isTerminalUrlWithHost:(nullable NSString *)urlHost {
    if (urlHost == nil) {
        return NO;
    }

    // check hardcoded Adjust terminal domains
    // these are domains where we stop recursion to avoid redirecting to App Store
    NSArray<NSString *> *_Nonnull terminalUrlHostSuffixArray =
        @[@"adjust.com",
          @"adj.st",
          @"go.link",
          @"adjust.cn",
          @"adjust.net.in",
          @"adjust.world",
          @"adjust.io"];

    return [ADJLinkResolution urlMatchesSuffixWithHost:urlHost
                                           suffixArray:terminalUrlHostSuffixArray];
}

+ (BOOL)urlMatchesSuffixWithHost:(nullable NSString *)urlHost
                     suffixArray:(nullable NSArray<NSString *> *)suffixArray {
    if (urlHost == nil) {
        return NO;
    }

    if (suffixArray == nil) {
        return NO;
    }

    for (NSString *_Nonnull expectedHostSuffix in suffixArray) {
        if ([urlHost hasSuffix:expectedHostSuffix]) {
            return YES;
        }
    }

    return NO;
}

@end
