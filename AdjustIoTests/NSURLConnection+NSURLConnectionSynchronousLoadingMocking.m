//
//  NSURLConnection+NSURLConnectionSynchronousLoadingMocking.m
//  AdjustIo
//
//  Created by Pedro Filipe on 12/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h"
#import "AIAdjustIoFactory.h"
#import "AILoggerMock.h"

@implementation NSURLConnection(NSURLConnectionSynchronousLoadingMock) 

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
    AILoggerMock *loggerMock =(AILoggerMock *)[AIAdjustIoFactory logger];
    [loggerMock test:@"NSURLConnection sendSynchronousRequest"];

    //  build response
    (*response) = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] init] statusCode:200 HTTPVersion:@"" headerFields:nil];

    //  encoded message reads "{"tracker_token":"token","tracker_name":"name"}"
    NSData *responseData = [[NSData alloc]
        initWithBase64EncodedString:@"eyJ0cmFja2VyX3Rva2VuIjoidG9rZW4iLCJ0cmFja2VyX25hbWUiOiJuYW1lIn0="
        options:NSDataBase64DecodingIgnoreUnknownCharacters];

    return responseData;
}

@end
