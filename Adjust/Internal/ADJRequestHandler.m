//
//  ADJRequestHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-04.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJActivityKind.h"
#import "ADJAdjustFactory.h"
#import "ADJPackageBuilder.h"
#import "ADJActivityPackage.h"
#import "ADJAdditions.h"
#import "ADJUserDefaults.h"
#include <stdlib.h>

static NSString * const ADJMethodGET = @"MethodGET";
static NSString * const ADJMethodPOST = @"MethodPOST";

@interface ADJRequestHandler()

@property (nonatomic, strong) ADJUrlStrategy *urlStrategy;
@property (nonatomic, assign) double requestTimeout;
@property (nonatomic, weak) id<ADJResponseCallback> responseCallback;
@property (nonatomic, strong) ADJConfig *adjustConfig;

@property (nonatomic, weak) id<ADJLogger> logger;

@property (nonatomic, copy) NSURLSessionConfiguration *defaultSessionConfiguration;

@property (nonatomic, strong) NSHashTable<NSString *> *exceptionKeys;

@end

@implementation ADJRequestHandler

#pragma mark - Public methods

- (id)initWithResponseCallback:(id<ADJResponseCallback>)responseCallback
                   urlStrategy:(ADJUrlStrategy *)urlStrategy
                requestTimeout:(double)requestTimeout
           adjustConfiguration:(ADJConfig *)adjustConfig
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    self.urlStrategy = urlStrategy;
    self.requestTimeout = requestTimeout;
    self.responseCallback = responseCallback;
    self.adjustConfig = adjustConfig;

    self.logger = ADJAdjustFactory.logger;
    self.defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];

    self.exceptionKeys = [NSHashTable hashTableWithOptions:NSHashTableStrongMemory];
    [self.exceptionKeys addObject:@"secret_id"];
    [self.exceptionKeys addObject:@"signature"];
    [self.exceptionKeys addObject:@"headers_id"];
    [self.exceptionKeys addObject:@"native_version"];
    [self.exceptionKeys addObject:@"algorithm"];
    [self.exceptionKeys addObject:@"adj_signing_id"];

    return self;
}

- (void)sendPackageByPOST:(ADJActivityPackage *)activityPackage
        sendingParameters:(NSDictionary *)sendingParameters
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]
                                       initWithDictionary:activityPackage.parameters
                                       copyItems:YES];
    NSString *path = [activityPackage.path copy];
    NSString *clientSdk = [activityPackage.clientSdk copy];
    ADJActivityKind activityKind = activityPackage.activityKind;

    NSDictionary *updatedSendingParameters = [self updateSendingParameters:sendingParameters];
    ADJResponseData *responseData = [ADJResponseData buildResponseData:activityPackage];
    NSString *urlHostString = [self urlWithParams:parameters
                                    sendingParams:updatedSendingParameters
                                     responseData:responseData];

    NSMutableDictionary *mergedParameters = [[NSMutableDictionary alloc]
                                          initWithDictionary:parameters];
    [mergedParameters addEntriesFromDictionary:responseData.sendingParameters];

    NSMutableDictionary<NSString *, NSString *> *_Nonnull outputParams =
        [self signWithSigPluginWithMergedParameters:mergedParameters
                                       activityKind:activityKind
                                          clientSdk:clientSdk
                                      urlHostString:urlHostString];

    NSString *_Nullable authorizationHeader = nil;

    if (outputParams.count > 0) {
        authorizationHeader = [outputParams objectForKey:@"authorization"];
        [outputParams removeObjectForKey:@"authorization"];

        if ([outputParams objectForKey:@"endpoint"] != nil) {
            urlHostString = [outputParams objectForKey:@"endpoint"];
        }
        [outputParams removeObjectForKey:@"endpoint"];

        mergedParameters = outputParams;
    }

    NSMutableURLRequest *urlRequest = [self requestForPostPackage:path
                                                        clientSdk:clientSdk
                                                 mergedParameters:mergedParameters
                                                    urlHostString:urlHostString];

    [self sendRequest:urlRequest
  authorizationHeader:authorizationHeader
         responseData:responseData
       methodTypeInfo:ADJMethodPOST];
}

- (void)sendPackageByGET:(ADJActivityPackage *)activityPackage
       sendingParameters:(NSDictionary *)sendingParameters
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]
                                       initWithDictionary:activityPackage.parameters
                                       copyItems:YES];
    NSString *path = [activityPackage.path copy];
    NSString *clientSdk = [activityPackage.clientSdk copy];
    ADJActivityKind activityKind = activityPackage.activityKind;

    NSDictionary *updatedSendingParameters = [self updateSendingParameters:sendingParameters];
    ADJResponseData *responseData = [ADJResponseData buildResponseData:activityPackage];
    NSString *urlHostString = [self urlWithParams:parameters
                                    sendingParams:updatedSendingParameters
                                     responseData:responseData];

    NSMutableDictionary *mergedParameters = [[NSMutableDictionary alloc]
                                          initWithDictionary:parameters];
    [mergedParameters addEntriesFromDictionary:responseData.sendingParameters];

    NSMutableDictionary<NSString *, NSString *> *_Nonnull outputParams =
        [self signWithSigPluginWithMergedParameters:mergedParameters
                                       activityKind:activityKind
                                          clientSdk:clientSdk
                                      urlHostString:urlHostString];

    NSString *_Nullable authorizationHeader = nil;

    if (outputParams.count > 0) {
        authorizationHeader = [outputParams objectForKey:@"authorization"];
        [outputParams removeObjectForKey:@"authorization"];

        if ([outputParams objectForKey:@"endpoint"] != nil) {
            urlHostString = [outputParams objectForKey:@"endpoint"];
        }
        [outputParams removeObjectForKey:@"endpoint"];

        mergedParameters = outputParams;
    }

    NSMutableURLRequest *urlRequest = [self requestForGetPackage:path
                                                       clientSdk:clientSdk
                                                mergedParameters:mergedParameters
                                                   urlHostString:urlHostString];

    [self sendRequest:urlRequest
  authorizationHeader:authorizationHeader
         responseData:responseData
       methodTypeInfo:ADJMethodGET];
}

#pragma mark - Internal methods
- (NSDictionary *)updateSendingParameters:(NSDictionary *)sendingParameters {
    NSMutableDictionary *updatedSendingParameters = [sendingParameters mutableCopy];
    if (updatedSendingParameters == nil) {
        updatedSendingParameters = [[NSMutableDictionary alloc] init];
    }

    NSString *dateString = [ADJUtil formatSeconds1970:[NSDate.date timeIntervalSince1970]];
    [updatedSendingParameters setValue:dateString forKey:@"sent_at"];
    
    return [updatedSendingParameters copy];
}

- (nonnull NSString *)urlWithParams:(nonnull NSMutableDictionary *)params
                      sendingParams:(NSDictionary *)sendingParams
                       responseData:(nonnull ADJResponseData *)responseData {
    NSMutableDictionary *sendingParamsCopy =  [NSMutableDictionary dictionaryWithDictionary:sendingParams];

    // checking consent related parameters at the package creation moment
    NSString *paramsAttStatusString = [responseData.sdkPackage.parameters objectForKey:@"att_status"];
    int paramsAttStatusInt = (paramsAttStatusString != nil) ? paramsAttStatusString.intValue : -1;
    BOOL wasConsentWhenCreated = [ADJUtil shouldUseConsentParamsForActivityKind:responseData.activityKind
                                                                   andAttStatus:paramsAttStatusInt];

    // checking consent related parameters at the package sending moment
    int currentAttStatus = -1;
    if (self.adjustConfig.isAppTrackingTransparencyUsageEnabled) {
        currentAttStatus = [ADJUtil attStatus];
    }
    BOOL isConsentWhenSending = [ADJUtil shouldUseConsentParamsForActivityKind:responseData.activityKind
                                                                  andAttStatus:currentAttStatus];
    if (wasConsentWhenCreated != isConsentWhenSending) {
        if (isConsentWhenSending) {
            [ADJPackageBuilder addConsentDataToParameters:params
                                            configuration:self.adjustConfig];
        } else {
            [ADJPackageBuilder removeConsentDataFromParameters:params];
        }
    }

    // if att_status was part of the payload at all, make sure to have up to date value before sending
    if (paramsAttStatusString != nil && currentAttStatus > -1) {
        [ADJPackageBuilder updateAttStatus:currentAttStatus inParameters:params];
    }

    NSString *urlHostString =  [self.urlStrategy urlForActivityKind:responseData.activityKind
                                                     isConsentGiven:isConsentWhenSending
                                                  withSendingParams:sendingParamsCopy];
    responseData.sendingParameters = [[NSDictionary alloc]
                                      initWithDictionary:sendingParamsCopy
                                      copyItems:YES];
    return urlHostString;
}

- (void)sendRequest:(NSMutableURLRequest *)request
authorizationHeader:(NSString *)authorizationHeader
       responseData:(ADJResponseData *)responseData
     methodTypeInfo:(NSString *)methodTypeInfo
{
    if (authorizationHeader != nil) {
        [ADJAdjustFactory.logger debug:@"Authorization header content: %@", authorizationHeader];
        [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
    }

    Class NSURLSessionClass = NSClassFromString(@"NSURLSession");
    if (NSURLSessionClass != nil) {
        [self sendNSURLSessionRequest:request
                      responseData:responseData
                       methodTypeInfo:methodTypeInfo];
    } else {
        [self sendNSURLConnectionRequest:request
                         responseData:responseData
                          methodTypeInfo:methodTypeInfo];
    }
}

- (void)sendNSURLSessionRequest:(NSMutableURLRequest *)request
                   responseData:(ADJResponseData *)responseData
                 methodTypeInfo:(NSString *)methodTypeInfo

{
    NSURLSession *session =
        [NSURLSession sessionWithConfiguration:self.defaultSessionConfiguration];

    NSURLSessionDataTask *task =
        [session dataTaskWithRequest:request
                   completionHandler:
         ^(NSData *data, NSURLResponse *response, NSError *error)
         {
            [self handleResponseWithData:data
                                response:(NSHTTPURLResponse *)response
                                   error:error
                            responseData:responseData];
            if (responseData.jsonResponse != nil) {
                [self.logger debug:@"Request succeeded with current URL strategy"];
                [self.urlStrategy resetAfterSuccess];
                [self.responseCallback responseCallback:responseData];
            } else {
                [responseData.sdkPackage addError:responseData.errorCode];
                if ([self.urlStrategy shouldRetryAfterFailure:responseData.activityKind]) {
                    [self.logger debug:@"Request failed with current URL strategy, but it will be retried with new one"];
                    [self retryWithResponseData:responseData
                                 methodTypeInfo:methodTypeInfo];
                } else {
                    [self.logger debug:@"Request failed with current URL strategy and it will not be retried"];
                    //  Stop retrying with different type and return to caller
                    [self.responseCallback responseCallback:responseData];
                }
            }
        }];

    [task resume];
    [session finishTasksAndInvalidate];
}

/* Manual testing code to fail certain percentage of requests
 // needs .h to comply with NSURLSessionDelegate
- (void)
    URLSession:(NSURLSession *)session
    didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
    completionHandler:
        (void (^)
            (NSURLSessionAuthChallengeDisposition disposition,
             NSURLCredential * _Nullable credential))completionHandler
{
    uint32_t randomNumber = arc4random_uniform(2);
    NSLog(@"URLSession:didReceiveChallenge:completionHandler: random number %d", randomNumber);
    if (randomNumber != 0) {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }

    //if (self.urlStrategy.usingIpAddress) {
    //    completionHandler(NSURLSessionAuthChallengeUseCredential,
    //                  [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    //} else {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    //}
}

 - (void)connection:(NSURLConnection *)connection
 willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
 {
     if (challenge.previousFailureCount > 0) {
         [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
     } else {
         NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
         [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
     }
 }
 */

- (void)sendNSURLConnectionRequest:(NSMutableURLRequest *)request
                responseData:(ADJResponseData *)responseData
                    methodTypeInfo:(NSString *)methodTypeInfo
{
    dispatch_async
        (dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
         ^{
            NSError *error = nil;
            NSURLResponse *response = nil;
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
            #pragma clang diagnostic pop

            [self handleResponseWithData:data
                                response:(NSHTTPURLResponse *)response
                                   error:error
                            responseData:responseData];

            if (responseData.jsonResponse != nil) {
                [self.logger debug:@"succeeded with current url strategy"];
                [self.urlStrategy resetAfterSuccess];
                [self.responseCallback responseCallback:responseData];
            } else if ([self.urlStrategy shouldRetryAfterFailure:responseData.activityKind]) {
                [self.logger debug:@"failed with current url strategy, but it will retry with new"];
                [self retryWithResponseData:responseData
                             methodTypeInfo:methodTypeInfo];
            } else {
                [self.logger debug:@"failed with current url strategy and it will not retry"];
                //  Stop retrying with different type and return to caller
                [self.responseCallback responseCallback:responseData];
            }
        });
}

- (void)retryWithResponseData:(ADJResponseData *)responseData
               methodTypeInfo:(NSString *)methodTypeInfo
{
    ADJActivityPackage *activityPackage = responseData.sdkPackage;
    NSDictionary *sendingParameters = responseData.sendingParameters;

    if (methodTypeInfo == ADJMethodGET) {
        [self sendPackageByGET:activityPackage
             sendingParameters:sendingParameters];
    } else {
        [self sendPackageByPOST:activityPackage
              sendingParameters:sendingParameters];
    }
}

- (void)handleResponseWithData:(NSData *)data
                      response:(NSHTTPURLResponse *)urlResponse
                         error:(NSError *)responseError
                       responseData:(ADJResponseData *)responseData
{
    // Connection error
    if (responseError != nil) {
        responseData.message = responseError.description;
        responseData.errorCode = [NSNumber numberWithInteger:responseError.code];
        return;
    }
    if ([ADJUtil isNull:data]) {
        responseData.message = @"nil response data";
        return;
    }

    // NSString *responseString = [[[NSString alloc]
    //                              initWithData:data encoding:NSUTF8StringEncoding] adjTrim];
    NSString *responseString = [ADJAdditions adjTrim:[[NSString alloc] initWithData:data
                                                                           encoding:NSUTF8StringEncoding]];
    NSInteger statusCode = urlResponse.statusCode;
    [self.logger verbose:@"Response: %@", responseString];

    if (statusCode == 429) {
        responseData.message = @"Too frequent requests to the endpoint (429)";
        return;
    }

    [self saveJsonResponse:data responseData:responseData];
    if (responseData.jsonResponse == nil) {
        return;
    }

    NSString *messageResponse = [responseData.jsonResponse objectForKey:@"message"];
    responseData.message = messageResponse;
    responseData.timestamp = [responseData.jsonResponse objectForKey:@"timestamp"];
    responseData.adid = [responseData.jsonResponse objectForKey:@"adid"];
    responseData.continueInMilli = [responseData.jsonResponse objectForKey:@"continue_in"];
    responseData.retryInMilli = [responseData.jsonResponse objectForKey:@"retry_in"];

    NSDictionary *controlParams = [responseData.jsonResponse objectForKey:@"control_params"];
    if (controlParams != nil) {
        [ADJUserDefaults saveControlParams:controlParams];
    }

    NSString *trackingState = [responseData.jsonResponse objectForKey:@"tracking_state"];
    if (trackingState != nil) {
        if ([trackingState isEqualToString:@"opted_out"]) {
            responseData.trackingState = ADJTrackingStateOptedOut;
        }
    }

    if (statusCode == 200) {
        responseData.success = YES;
    }
}
#pragma mark - URL Request
- (NSMutableURLRequest *)
    requestForPostPackage:(NSString *)path
    clientSdk:(NSString *)clientSdk
    mergedParameters:(NSDictionary *)mergedParameters
    urlHostString:(NSString *)urlHostString
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",
                           urlHostString, self.urlStrategy.extraPath, path];

    [self.logger verbose:@"Sending request to endpoint: %@", urlString];

    NSURL *url = [NSURL URLWithString:urlString];
    //NSURL *url = [baseUrl URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = self.requestTimeout;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:clientSdk forHTTPHeaderField:@"Client-Sdk"];
    // in case of beta release, specify build version here
    // [request setValue:@"1" forHTTPHeaderField:@"Beta-Version"];

    NSMutableArray<NSString *> *kvParameters =
        [NSMutableArray arrayWithCapacity:mergedParameters.count];

    [self injectParameters:mergedParameters kvArray:kvParameters];

    NSString *bodyString = [kvParameters componentsJoinedByString:@"&"];
    NSData *body = [NSData dataWithBytes:bodyString.UTF8String length:bodyString.length];
    [request setHTTPBody:body];
    return request;
}

- (NSMutableURLRequest *)
    requestForGetPackage:(NSString *)path
    clientSdk:(NSString *)clientSdk
    mergedParameters:(NSDictionary *)mergedParameters
    urlHostString:(NSString *)urlHostString
{
    NSMutableArray<NSString *> *kvParameters =
        [NSMutableArray arrayWithCapacity:mergedParameters.count];

    [self injectParameters:mergedParameters
        kvArray:kvParameters];

    NSString *queryStringParameters = [kvParameters componentsJoinedByString:@"&"];

    NSString *urlString =
        [NSString stringWithFormat:@"%@%@%@?%@",
         urlHostString, self.urlStrategy.extraPath, path, queryStringParameters];
    
    [self.logger verbose:@"Sending request to endpoint: %@",
     [NSString stringWithFormat:@"%@%@%@", urlHostString, self.urlStrategy.extraPath, path]];

    // [self.logger verbose:@"requestForGetPackage with urlString: %@", urlString];

    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = self.requestTimeout;
    request.HTTPMethod = @"GET";
    [request setValue:clientSdk forHTTPHeaderField:@"Client-Sdk"];
    // in case of beta release, specify build version here
    // [request setValue:@"1" forHTTPHeaderField:@"Beta-Version"];
    return request;
}

- (void)
    injectParameters:(NSDictionary<NSString *, NSString *> *)parameters
    kvArray:(NSMutableArray<NSString *> *)kvArray
{
    if (parameters == nil || parameters.count == 0) {
        return;
    }

    for (NSString *key in parameters) {
        if ([self.exceptionKeys containsObject:key]) {
            continue;
        }
        NSString *value = [parameters objectForKey:key];
        // NSString *escapedValue = [value  adjUrlEncode];
        NSString *escapedValue = [ADJAdditions adjUrlEncode:value];
        // NSString *escapedKey = [key  adjUrlEncode];
        NSString *escapedKey = [ADJAdditions adjUrlEncode:key];
        NSString *pair = [NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue];
        [kvArray addObject:pair];
    }
}

#pragma mark - JSON
- (void)saveJsonResponse:(NSData *)jsonData responseData:(ADJResponseData *)responseData {
    NSError *error = nil;
    NSException *exception = nil;
    NSDictionary *jsonDict =
        [self buildJsonDict:jsonData exceptionPtr:&exception errorPtr:&error];

    if (exception != nil) {
        responseData.message =
            [NSString stringWithFormat:
                @"Failed to parse json response. (%@)", exception.description];
    } else if (error != nil) {
        responseData.message =
            [NSString stringWithFormat:
                @"Failed to parse json response. (%@)", error.localizedDescription];
    } else if ([ADJUtil isNull:jsonDict]) {
        responseData.message = [NSString stringWithFormat:@"Failed to parse json response "];
    } else {
        responseData.jsonResponse = jsonDict;
    }
}

- (NSDictionary *)buildJsonDict:(NSData *)jsonData
                   exceptionPtr:(NSException **)exceptionPtr
                       errorPtr:(NSError **)error {
    if (jsonData == nil) {
        return nil;
    }

    NSDictionary *jsonDict = nil;
    @try {
        jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
    } @catch (NSException *ex) {
        *exceptionPtr = ex;
        return nil;
    }
    return jsonDict;
}

- (nonnull NSMutableDictionary<NSString *, NSString *> *)
    signWithSigPluginWithMergedParameters:
        (nonnull NSDictionary<NSString *, NSString *> *)mergedParameters
    activityKind:(ADJActivityKind)activityKind
    clientSdk:(nonnull NSString *)clientSdk
    urlHostString:(nonnull NSString *)urlHostString
{
    NSMutableDictionary<NSString *, NSString *> *_Nonnull outputParams =
        [NSMutableDictionary dictionary];

    _Nullable Class signerClass = NSClassFromString(@"ADJSigner");
    if (signerClass == nil) {
        return outputParams;
    }
    _Nonnull SEL signSEL = NSSelectorFromString(@"sign:withExtraParams:withOutputParams:");
    if (![signerClass respondsToSelector:signSEL]) {
        return outputParams;
    }

    NSMutableDictionary<NSString *, NSString *> *_Nonnull extraParams =
        [NSMutableDictionary dictionary];

    [extraParams setObject:clientSdk forKey:@"client_sdk"];

    [extraParams setObject:[ADJActivityKindUtil activityKindToString:activityKind]
                    forKey:@"activity_kind"];

    [extraParams setObject:urlHostString forKey:@"endpoint"];

    NSDictionary<NSString *, NSString *> *_Nullable controlParams =
        [ADJUserDefaults getControlParams];
    if (controlParams != nil) {
        for (NSString *_Nonnull controlParamsKey in controlParams) {
            NSString *_Nonnull controlParamsValue = [controlParams objectForKey:controlParamsKey];

            [extraParams setObject:controlParamsValue forKey:controlParamsKey];
        }
    }

    /*
     [ADJSigner sign:packageParams
      withExtraParams:extraParams
     withOutputParams:outputParams];
     */

    NSMethodSignature *signMethodSignature = [signerClass methodSignatureForSelector:signSEL];
    NSInvocation *signInvocation = [NSInvocation invocationWithMethodSignature:signMethodSignature];
    [signInvocation setSelector:signSEL];
    [signInvocation setTarget:signerClass];

    [signInvocation setArgument:&mergedParameters atIndex:2];
    [signInvocation setArgument:&extraParams atIndex:3];
    [signInvocation setArgument:&outputParams atIndex:4];

    [signInvocation invoke];

    return outputParams;
}

@end
