//
//  AIRequestHandler.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 2013-07-04.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIRequestHandler.h"
#import "AIPackageHandler.h"
#import "AIActivityPackage.h"
#import "AILogger.h"
#import "AIUtil.h"
#import "NSString+AIAdditions.h"
#import "AIAdjustIoFactory.h"

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
    self.logger = [AIAdjustIoFactory getLogger];
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
        [self.logger error:@"%@. (%@) Will retry later.", package.failureMessage, error.localizedDescription];
        [self.packageHandler closeFirstPackage];
        return;
    }

    // wrong status code
    if (response.statusCode != 200) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self.logger error:@"%@. (%@)", package.failureMessage, responseString.aiTrim];
        [self.packageHandler sendNextPackage];
        return;
    }

    // success
    [self.logger info:@"%@", package.successMessage];
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

    NSString *bodyString = [pairs componentsJoinedByString:@"&"];
    NSData *body = [NSData dataWithBytes:bodyString.UTF8String length:bodyString.length];
    return body;
}

@end
