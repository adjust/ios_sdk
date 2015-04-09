//
//  NSURLConnection+NSURLConnectionSynchronousLoadingMocking.m
//  Adjust
//
//  Created by Pedro Filipe on 12/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//
#import "NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h"
#import "ADJAdjustFactory.h"
#import "ADJLoggerMock.h"

static BOOL triggerConnectionError = NO;
static int triggerResponse = 0;

@implementation NSURLConnection(NSURLConnectionSynchronousLoadingMock)

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
    ADJLoggerMock *loggerMock =(ADJLoggerMock *)ADJAdjustFactory.logger;
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
    if (triggerResponse == 0) {
        statusCode = 200;
        sResponse = @"{\"attribution\":{\"tracker_token\":\"trackerTokenValue\",\"tracker_name\":\"trackerNameValue\",\"network\":\"networkValue\",\"campaign\":\"campaignValue\",\"adgroup\":\"adgroupValue\",\"creative\":\"creativeValue\",\"click_label\":\"clickLabelValue\"},\"message\":\"response OK\",\"deeplink\":\"testApp://\"}";
    } else if (triggerResponse == 1) {
        statusCode = 0;
        sResponse = @"{\"message\":\"response error\"}";
    } else if (triggerResponse == 2) {
        statusCode = 0;
        sResponse = @"server response";
    } else if (triggerResponse == 3) {
        statusCode = 0;
        sResponse = @"{}";
    } else if (triggerResponse == 4) {
        statusCode = 200;
        sResponse = @"{\"attribution\":{\"tracker_token\":\"trackerTokenValue\",\"tracker_name\":\"trackerNameValue\",\"network\":\"networkValue\",\"campaign\":\"campaignValue\",\"adgroup\":\"adgroupValue\",\"creative\":\"creativeValue\",\"click_label\":\"clickLabelValue\"}, \"message\":\"response OK\",\"ask_in\":\"2000\"}";
    } else {

        statusCode = 0;
        sResponse = @"";
    }
    //  build response
    (*response) = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] init] statusCode:statusCode HTTPVersion:@"" headerFields:nil];

    NSData *responseData = [sResponse dataUsingEncoding:NSUTF8StringEncoding];

    return responseData;
}

+ (void)setConnectionError:(BOOL)connection {
    triggerConnectionError = connection;
}

+ (void)setResponse:(int)response {
    triggerResponse = response;
}



@end
