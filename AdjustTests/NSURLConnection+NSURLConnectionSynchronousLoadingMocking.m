//
//  NSURLConnection+NSURLConnectionSynchronousLoadingMocking.m
//  Adjust
//
//  Created by Pedro Filipe on 12/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//
#import "NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h"
#import "AIAdjustFactory.h"
#import "AILoggerMock.h"

static BOOL triggerConnectionError = NO;
static BOOL triggerResponseError = NO;

@implementation NSURLConnection(NSURLConnectionSynchronousLoadingMock)

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
    AILoggerMock *loggerMock =(AILoggerMock *)AIAdjustFactory.logger;
    [loggerMock test:@"NSURLConnection sendSynchronousRequest"];

    if (triggerConnectionError) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"connection error", nil) };
        (*error) = [NSError errorWithDomain:@"Adjust"
                                             code:-57
                                         userInfo:userInfo];
        return nil;
    }
    NSInteger statusCode;
    NSString * sResponse;
    if (triggerResponseError) {
        statusCode = 0;
        sResponse = @"{\"error\":\"response error\"}";
    } else {
        statusCode = 200;
        sResponse = @"{\"tracker_token\":\"token\",\"tracker_name\":\"name\", \"network\":\"network\",\"campaign\":\"campaign\", \"adgroup\":\"adgroup\",\"creative\":\"creative\",\"deeplink\":\"testApp://\"}";
    }
    //  build response
    (*response) = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] init] statusCode:statusCode HTTPVersion:@"" headerFields:nil];

    NSData *responseData = [sResponse dataUsingEncoding:NSUTF8StringEncoding];

    return responseData;
}

+ (void)setConnectionError:(BOOL)connection {
    triggerConnectionError = connection;
}

+ (void)setResponseError:(BOOL)response {
    triggerResponseError = response;
}

@end
