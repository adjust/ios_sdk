//
//  ADJRequestHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-04.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJActivityPackage.h"
#import "ADJLogger.h"
#import "ADJUtil.h"
#import "NSString+ADJAdditions.h"
#import "ADJAdjustFactory.h"

static const char * const kInternalQueueName = "io.adjust.RequestQueue";
static const double kRequestTimeout = 60; // 60 seconds


#pragma mark - private
@interface ADJRequestHandler()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, assign) id<ADJPackageHandler> packageHandler;
@property (nonatomic, assign) id<ADJLogger> logger;
@property (nonatomic, retain) NSURL *baseUrl;

@end


#pragma mark -
@implementation ADJRequestHandler

+ (ADJRequestHandler *)handlerWithPackageHandler:(id<ADJPackageHandler>)packageHandler {
    return [[ADJRequestHandler alloc] initWithPackageHandler:packageHandler];
}

- (id)initWithPackageHandler:(id<ADJPackageHandler>) packageHandler {
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.packageHandler = packageHandler;
    self.logger = ADJAdjustFactory.logger;
    self.baseUrl = [NSURL URLWithString:ADJUtil.baseUrl];

    return self;
}

- (void)sendPackage:(ADJActivityPackage *)activityPackage {
    dispatch_async(self.internalQueue, ^{
        [self sendInternal:activityPackage sendToPackageHandler:YES];
    });
}

- (void)sendClickPackage:(ADJActivityPackage *)clickPackage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self sendInternal:clickPackage sendToPackageHandler:NO];
    });
}


#pragma mark - internal
- (void)sendInternal:(ADJActivityPackage *)package sendToPackageHandler:(BOOL)sendToPackageHandler{
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
        [self.packageHandler finishedTrackingActivity:nil];
        if (sendToPackageHandler) {
            [self.packageHandler closeFirstPackage];
        }
        return;
    }

    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.logger verbose:@"package response: %@", responseString];

    NSDictionary *jsonDict = [ADJUtil buildJsonDict:responseString];
    NSString* messageResponse = [jsonDict objectForKey:@"message"];

    NSInteger statusCode = response.statusCode;
    if (statusCode == 200) {
        [self.logger info:@"status code %d with message %@", statusCode, messageResponse];
    } else {
        [self.logger error:@"status code %d with message %@", statusCode, messageResponse];
    }


    [self.packageHandler finishedTrackingActivity:jsonDict];
    if (sendToPackageHandler) {
        [self.packageHandler sendNextPackage];
    }
}

#pragma mark - private
- (NSMutableURLRequest *)requestForPackage:(ADJActivityPackage *)package {
    NSURL *url = [NSURL URLWithString:package.path relativeToURL:self.baseUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"POST";

    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:package.clientSdk forHTTPHeaderField:@"Client-Sdk"];
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
    NSString *dateString = [ADJUtil dateFormat:now];
    NSString *escapedDate = [dateString aiUrlEncode];
    NSString *sentAtPair = [NSString stringWithFormat:@"%@=%@", @"sent_at", escapedDate];
    [pairs addObject:sentAtPair];

    NSString *bodyString = [pairs componentsJoinedByString:@"&"];
    NSData *body = [NSData dataWithBytes:bodyString.UTF8String length:bodyString.length];
    return body;
}

- (void) checkMessageResponse:(NSDictionary *)jsonDict {
    if (jsonDict == nil) return;

    NSString* messageResponse = [jsonDict objectForKey:@"message"];
    if (messageResponse != nil) {
        [self.logger info:messageResponse];
    }
}

- (void)checkErrorResponse:(NSDictionary *)jsonDict {
    if (jsonDict == nil) return;

    NSString* errorResponse = [jsonDict objectForKey:@"error"];
    if (errorResponse != nil) {
        [self.logger error:errorResponse];
    }
}

@end
