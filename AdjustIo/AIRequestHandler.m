//
//  AIRequestHandler.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 04.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIRequestHandler.h"
#import "AIPackageHandler.h"
#import "AIActivityPackage.h"
#import "AILogger.h"
#import "AIUtil.h"
#import "NSString+AIAdditions.h"
#import "AFNetworking.h"

static const char * const kInternalQueueName = "io.adjust.RequestQueue";
static const double  kRequestTimeout = 2.0; // TODO: 60


#pragma mark - private
@interface AIRequestHandler()

@property (nonatomic, retain) dispatch_queue_t internalQueue;
@property (nonatomic, assign) AIPackageHandler *packageHandler;
@property (nonatomic, retain) AFHTTPClient *httpClient;

@end


#pragma mark -
@implementation AIRequestHandler

+ (AIRequestHandler *)handlerWithPackageHandler:(AIPackageHandler *)packageHandler {
    return [[AIRequestHandler alloc] initWithPackageHandler:packageHandler];
}

- (id)initWithPackageHandler:(AIPackageHandler *)packageHandler {
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.packageHandler = packageHandler;

    dispatch_async(self.internalQueue, ^{
        [self initInternal];
    });

    return self;
}

- (void)sendPackage:(AIActivityPackage *)activityPackage {
    dispatch_async(self.internalQueue, ^{
        [self sendInternal:activityPackage];
    });
}


#pragma mark - private
- (void)packageSucceeded:(AIActivityPackage *)package {
    dispatch_async(self.internalQueue, ^{
        [self successInternal:package];
    });
}

- (void)packageFailed:(AIActivityPackage *)package response:(NSString *)response error:(NSError *)error {
    dispatch_async(self.internalQueue, ^{
        [self failureInternal:package response:response error:error];
    });
}

#pragma mark - internal
- (void)initInternal {
    self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:AIUtil.baseUrl]];
}

- (void)sendInternal:(AIActivityPackage *)package {
    if (self.packageHandler == nil) return;

    [self setHttpHeaders:package];
    NSMutableURLRequest *request = [self requestForPackage:package];
    AFHTTPRequestOperation *op = [self getOperationForPackage:package request:request];
    [self.httpClient enqueueHTTPRequestOperation:op];
}

// TODO: test status response codes other than 200 (should retry later)
- (void)successInternal:(AIActivityPackage *)package {
    if (self.packageHandler == nil) return;

    [AILogger info:@"%@", package.successMessage];
    [self.packageHandler sendNextPackage];
}

- (void)failureInternal:(AIActivityPackage *)package response:(NSString *)response error:(NSError *)error {
    if (self.packageHandler == nil) return;

    if (response == nil || response.length == 0) {
        [AILogger error:@"%@. (%@) Will retry later.", package.failureMessage, error.localizedDescription];
        [self.packageHandler closeFirstPackage];
        return;
    }

    [AILogger error:@"%@. (%@)", package.failureMessage, response.aiTrim];
    [self.packageHandler sendNextPackage];
}

#pragma mark - private
- (NSMutableURLRequest *)requestForPackage:(AIActivityPackage *)activityPackage {
    NSString *path = activityPackage.path;
    NSDictionary *parameters = activityPackage.parameters;
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"POST" path:path parameters:parameters];
    request.timeoutInterval = kRequestTimeout;

    return request;
}

- (AFHTTPRequestOperation *)getOperationForPackage:(AIActivityPackage *)package request:(NSURLRequest *)request {
    // note: these blocks will get executed on the main thread
    void (^success)(AFHTTPRequestOperation *op, id resp) = ^(AFHTTPRequestOperation *op, id resp) {
        [self packageSucceeded:package];
    };

    void (^failure)(AFHTTPRequestOperation *op, NSError *err) = ^(AFHTTPRequestOperation *op, NSError *err) {
        [self packageFailed:package response:op.responseString error:err];
    };

    return [self.httpClient HTTPRequestOperationWithRequest:request success:success failure:failure];
}

- (void)setHttpHeaders:(AIActivityPackage *)activityPackage {
    [self.httpClient setDefaultHeader:@"User-Agent" value:activityPackage.userAgent];
    [self.httpClient setDefaultHeader:@"Client-SDK" value:activityPackage.clientSdk];
}

@end
