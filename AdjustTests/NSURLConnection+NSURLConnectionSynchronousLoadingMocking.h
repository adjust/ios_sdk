//
//  NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h
//  Adjust
//
//  Created by Pedro Filipe on 12/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection(NSURLConnectionSynchronousLoadingMock)

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

+ (void)setConnectionError:(BOOL)connection;
+ (void)setResponseError:(BOOL)response;

@end
