//
//  AIRequestHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-04.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "AIRequestHandler.h"
#import "AIPackageHandler.h"
#import "AIActivityPackage.h"
#import "AIResponseData.h"
#import "AILogger.h"
#import "AIUtil.h"
#import "NSString+AIAdditions.h"
#import "AIAdjustFactory.h"

static const char * const kInternalQueueName = "io.adjust.RequestQueue";
static const double kRequestTimeout = 60; // 60 seconds


#pragma mark - private
@interface AIRequestHandler()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, assign) id<AIPackageHandler> packageHandler;
@property (nonatomic, assign) id<AILogger> logger;
@property (nonatomic, retain) NSURL *baseUrl;

@end


#pragma mark -
@implementation AIRequestHandler

+ (AIRequestHandler *)handlerWithPackageHandler:(id<AIPackageHandler>)packageHandler {
    return [[AIRequestHandler alloc] initWithPackageHandler:packageHandler];
}

- (id)initWithPackageHandler:(id<AIPackageHandler>) packageHandler {
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.packageHandler = packageHandler;
    self.logger = AIAdjustFactory.logger;
    self.baseUrl = [NSURL URLWithString:AIUtil.baseUrl];

    return self;
}

- (void)sendPackage:(AIActivityPackage *)activityPackage {
    dispatch_async(self.internalQueue, ^{
        [self sendInternal:activityPackage];
    });
}


#pragma mark - internal
- (void)sendInternal:(AIActivityPackage *)package {
    if (self.packageHandler == nil) return;

    NSMutableURLRequest *request = [self requestForPackage:package];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];

    // connection error
    if (error != nil) {
        AIResponseData *responseData = [AIResponseData dataWithError:error.localizedDescription];
        responseData.willRetry = YES;
        [self.logger error:@"%@. (%@) Will retry later.", package.failureMessage, responseData.error];
        [self.packageHandler finishedTrackingActivity:package withResponse:responseData];
        [self.packageHandler closeFirstPackage];
        return;
    }

    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AIResponseData *responseData = [AIResponseData dataWithJsonString:responseString];

    if (response.statusCode == 200) {
        // success
        responseData.success = YES;
        [self.logger info:@"%@", package.successMessage];
    } else {
        // wrong status code
        [self.logger error:@"%@. (%@)", package.failureMessage, responseData.error];
    }

    [self.packageHandler finishedTrackingActivity:package withResponse:responseData];
    [self.packageHandler sendNextPackage];
}

#pragma mark - private
- (NSMutableURLRequest *)requestForPackage:(AIActivityPackage *)package {
    NSURL *url = [NSURL URLWithString:package.path relativeToURL:self.baseUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"POST";

    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:package.clientSdk forHTTPHeaderField:@"Client-Sdk"];
    [request setValue:package.userAgent forHTTPHeaderField:@"User-Agent"];
    [request setHTTPBody:[self bodyForParameters:package.parameters]];

    return request;
}

- (NSData *)bodyForParameters:(NSDictionary *)parameters {
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in parameters) {
        NSString *value = [parameters objectForKey:key];
        NSString *escapedValue = [value aiUrlEncode];
        NSString *pair = [NSString stringWithFormat:@"%@=%@", key, escapedValue];
        [pairs addObject:pair];
    }

    double now = [NSDate.date timeIntervalSince1970];
    NSString *dateString = [AIUtil dateFormat:now];
    NSString *escapedDate = [dateString aiUrlEncode];
    NSString *sentAtPair = [NSString stringWithFormat:@"%@=%@", @"sent_at", escapedDate];
    [pairs addObject:sentAtPair];

    NSString *bodyString = [pairs componentsJoinedByString:@"&"];
    NSData *body = [NSData dataWithBytes:bodyString.UTF8String length:bodyString.length];
    return body;
}

@end
