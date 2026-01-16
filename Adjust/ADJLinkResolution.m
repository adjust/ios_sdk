//
//  ADJLinkResolution.m
//  Adjust
//
//  Created by Pedro Silva (@nonelse) on 26th April 2021.
//  Copyright © 2021-Present Adjust GmbH. All rights reserved.
//

#import "ADJLinkResolution.h"
#import "ADJUtil.h"
static NSUInteger kMaxRecursions = 10;

// forward declaration for private methods
@interface ADJLinkResolution (Private)
+ (BOOL)isTerminalUrlWithHost:(nullable NSString *)urlHost;
+ (nullable NSURL *)convertUrlToHttps:(nullable NSURL *)url;
+ (nullable NSString *)locationHeaderFromResponse:(nonnull NSHTTPURLResponse *)response;
+ (nonnull NSURLSession *)linkResolutionSession;
+ (void)requestAndResolveUrl:(nonnull NSURL *)url
                   recursion:(NSUInteger)recursionNumber
                    callback:(nonnull void (^)(NSURL *_Nullable resolvedLink))callback;
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
    // prevent automatic redirects so we can resolve manually
    completionHandler(nil);
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
    if (!resolveUrlSuffixArray || ![self urlMatchesSuffixWithHost:url.host
                                                      suffixArray:resolveUrlSuffixArray]) {
        [ADJUtil launchInMainThread:^{
            callback(url);
        }];
        return;
    }

    // convert HTTP to HTTPS for initial URL
    NSURL *httpsUrl = [self convertUrlToHttps:url];

    [self requestAndResolveUrl:httpsUrl
                     recursion:0
                       callback:callback];
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

+ (nullable NSString *)locationHeaderFromResponse:(nonnull NSHTTPURLResponse *)response {
    NSDictionary *headers = response.allHeaderFields;
    for (id key in headers) {
        if ([key isKindOfClass:[NSString class]] &&
            [(NSString *)key caseInsensitiveCompare:@"Location"] == NSOrderedSame) {
            id value = headers[key];
            return [value isKindOfClass:[NSString class]] ? value : nil;
        }
    }
    return nil;
}

+ (nonnull NSURLSession *)linkResolutionSession {
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
    return sharedSession;
}

+ (void)requestAndResolveUrl:(nonnull NSURL *)url
                   recursion:(NSUInteger)recursionNumber
                    callback:(nonnull void (^)(NSURL *_Nullable resolvedLink))callback {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";

    NSURLSession *session = [self linkResolutionSession];
    __block NSURLSessionDataTask *task =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData * _Nullable data,
                                   NSURLResponse * _Nullable response,
                                   NSError * _Nullable error) {
        NSURL *finalUrl = response.URL ?: (error ? task.currentRequest.URL : url) ?: url;
        if (error != nil) {
            [ADJUtil launchInMainThread:^{
                callback(finalUrl);
            }];
            return;
        }

        NSHTTPURLResponse *httpResponse = [response isKindOfClass:[NSHTTPURLResponse class]]
            ? (NSHTTPURLResponse *)response
            : nil;
        if (httpResponse == nil) {
            [ADJUtil launchInMainThread:^{
                callback(finalUrl);
            }];
            return;
        }

        NSString *location = [self locationHeaderFromResponse:httpResponse];
        if (location.length > 0) {
            NSURL *redirectUrl = [NSURL URLWithString:location relativeToURL:finalUrl];
            redirectUrl = [self convertUrlToHttps:redirectUrl.absoluteURL];

            if (redirectUrl == nil) {
                [ADJUtil launchInMainThread:^{
                    callback(finalUrl);
                }];
                return;
            }

            if ([self isTerminalUrlWithHost:redirectUrl.host]) {
                [ADJUtil launchInMainThread:^{
                    callback(redirectUrl);
                }];
                return;
            }

            if (recursionNumber + 1 > kMaxRecursions) {
                [ADJUtil launchInMainThread:^{
                    callback(redirectUrl);
                }];
                return;
            }

            [self requestAndResolveUrl:redirectUrl
                             recursion:recursionNumber + 1
                              callback:callback];
            return;
        }

        [ADJUtil launchInMainThread:^{
            callback(finalUrl);
        }];
    }];
    [task resume];
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
