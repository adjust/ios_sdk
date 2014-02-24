//
//  NSURLConnection+NSURLConnectionSynchronousLoadingMocking.m
//  Adjust
//
//  Created by Pedro Filipe on 12/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
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
    NSString * sResponseBase64;
    if (triggerResponseError) {
        statusCode = 0;
        //  encoded from "{"error":"response error","tracker_token":"token","tracker_name":"name"}"
        sResponseBase64 = @"eyJlcnJvciI6InJlc3BvbnNlIGVycm9yIiwidHJhY2tlcl90b2tlbiI6InRva2VuIiwidHJhY2tlcl9uYW1lIjoibmFtZSJ9";
    } else {
        statusCode = 200;
        //  encoded from "{"tracker_token":"token","tracker_name":"name"}"
        sResponseBase64 = @"eyJ0cmFja2VyX3Rva2VuIjoidG9rZW4iLCJ0cmFja2VyX25hbWUiOiJuYW1lIn0=";
    }
    //  build response
    (*response) = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] init] statusCode:statusCode HTTPVersion:@"" headerFields:nil];

    NSData *responseData = [[NSData alloc]
        initWithBase64EncodedString:sResponseBase64
        options:NSDataBase64DecodingIgnoreUnknownCharacters];

    return responseData;
}

+ (void)setConnectionError:(BOOL)connection {
    triggerConnectionError = connection;
}

+ (void)setResponseError:(BOOL)response {
    triggerResponseError = response;
}

@end
