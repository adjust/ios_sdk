//
//  ATLNetworking.m
//  AdjustTestLibrary
//
//  Created by Pedro Silva on 24.05.24.
//  Copyright © 2024 adjust. All rights reserved.
//

#import "ATLNetworking.h"
#import "ATLUtil.h"

static const double kRequestTimeout = 60;   // 60 seconds

@implementation ATLHttpResponse
@end

@implementation ATLHttpRequest
- (nonnull id)initWithPath:(nonnull NSString *)path
                      base:(nullable NSString *)base
{
    self = [super init];
    _path = path;
    _base = base;

    return self;
}

@end

@interface ATLNetworking ()

@property (nonatomic, nonnull, strong) NSURLSessionConfiguration *urlSessionConfiguration;

@end

@implementation ATLNetworking

- (nonnull instancetype)init {
    self = [super init];
    _urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];

    return self;
}

- (void)sendPostRequestWithData:(nonnull ATLHttpRequest *)requestData
                        baseUrl:(nonnull NSURL *)baseUrl
                responseHandler:(nonnull httpResponseHandler)responseHandler
{
    NSMutableURLRequest *_Nullable request = [self requestWithData:requestData
                                                            baseUrl:baseUrl];
    if (request == nil) {
        return;
    }

    Class NSURLSessionClass = NSClassFromString(@"NSURLSession");

    if (NSURLSessionClass != nil) {
        [self sendNSURLSessionRequest:request
                      responseHandler:responseHandler];
    } else {
        [self sendNSURLConnectionRequest:request
                         responseHandler:responseHandler];
    }
}

- (nullable NSMutableURLRequest *)requestWithData:(nonnull ATLHttpRequest *)requestData
                                          baseUrl:(nonnull NSURL *)baseUrl
{
    NSString *_Nonnull mergedPath = requestData.base == nil ?
        requestData.path : [NSString stringWithFormat:@"%@%@", requestData.base, requestData.path];

    NSURL *_Nullable url = [NSURL URLWithString:mergedPath relativeToURL:baseUrl];
    if (url == nil) {
        return nil;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"POST";

    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    if (requestData.headerFields != nil) {
        for (NSString *key in requestData.headerFields) {
            [request setValue:requestData.headerFields[key] forHTTPHeaderField:key];
        }
    }

    if (requestData.bodyString != nil) {
        NSData *body = [NSData dataWithBytes:requestData.bodyString.UTF8String length:requestData.bodyString.length];
        [request setHTTPBody:body];
    }

    return request;
}

- (void)sendNSURLSessionRequest:(nonnull NSMutableURLRequest *)request
                responseHandler:(nonnull httpResponseHandler)responseHandler
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.urlSessionConfiguration
                                                delegate:nil
                                           delegateQueue:nil];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      responseHandler([ATLNetworking
                                                       completionHandler:data
                                                       response:(NSHTTPURLResponse *)response
                                                       error:error]);
                                  }];

    [task resume];
    [session finishTasksAndInvalidate];
}

- (void)sendNSURLConnectionRequest:(NSMutableURLRequest *)request
                   responseHandler:(httpResponseHandler)responseHandler
{
    NSError *responseError = nil;
    NSHTTPURLResponse *urlResponse = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&urlResponse
                                                     error:&responseError];
#pragma clang diagnostic pop

    responseHandler([ATLNetworking completionHandler:data
                                            response:(NSHTTPURLResponse *)urlResponse
                                               error:responseError]);
}

+ (ATLHttpResponse *)completionHandler:(NSData *)data
                              response:(NSHTTPURLResponse *)urlResponse
                                 error:(NSError *)responseError
{
    ATLHttpResponse *httpResponseData = [[ATLHttpResponse alloc] init];

    // Connection error
    if (responseError != nil) {
        [ATLUtil debug:@"responseError %@", responseError.localizedDescription];

        return httpResponseData;
    }

    if ([ATLUtil isNull:data]) {
        [ATLUtil debug:@"data is null %@"];

        return httpResponseData;
    }

    httpResponseData.responseString = [ATLUtil adjTrim:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    [ATLUtil debug:@"Response: %@", httpResponseData.responseString];

    httpResponseData.statusCode = urlResponse.statusCode;

    httpResponseData.headerFields = urlResponse.allHeaderFields;
    [ATLUtil debug:@"header fields: %@", httpResponseData.headerFields];

    httpResponseData.jsonFoundation = [ATLNetworking saveJsonResponse:data];
    [ATLUtil debug:@"json response: %@", httpResponseData.jsonFoundation];

    [ATLUtil debug:@"json response class: %@", NSStringFromClass([httpResponseData.jsonFoundation class])];
    //2const char * cStringClassName = object_getClassName(httpResponseData.jsonFoundation);

    return httpResponseData;
}

+ (id)saveJsonResponse:(NSData *)jsonData {
    NSError *error = nil;
    NSException *exception = nil;
    id jsonFoundation = [ATLNetworking buildJsonFoundation:jsonData
                                              exceptionPtr:&exception
                                                  errorPtr:&error];

    if (exception != nil) {
        [ATLUtil debug:@"Failed to parse json response. (%@)", exception.description];

        return nil;
    }

    if (error != nil) {
        [ATLUtil debug:@"Failed to parse json response. (%@)", error.description];

        return nil;
    }

    return jsonFoundation;
}

+ (id)buildJsonFoundation:(NSData *)jsonData
               exceptionPtr:(NSException **)exceptionPtr
                   errorPtr:(NSError **)error {
    if (jsonData == nil) {
        return nil;
    }

    id jsonFoundation = nil;

    @try {
        jsonFoundation = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
    } @catch (NSException *ex) {
        *exceptionPtr = ex;
        return nil;
    }

    return jsonFoundation;
}

@end
