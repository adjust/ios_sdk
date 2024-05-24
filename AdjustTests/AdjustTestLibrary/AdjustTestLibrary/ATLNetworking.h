//
//  ATLNetworking.h
//  AdjustTestLibrary
//
//  Created by Pedro Silva on 24.05.24.
//  Copyright © 2024 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATLHttpResponse : NSObject

@property (nonatomic, nullable, strong) NSString * responseString;
@property (nonatomic, nullable, strong) id jsonFoundation;
@property (nonatomic, nullable, strong) NSDictionary *headerFields;
@property (nonatomic, assign) NSInteger statusCode;

@end

@interface ATLHttpRequest : NSObject

@property (nonatomic, nonnull, readonly, strong) NSString *path;
@property (nonatomic, nullable, readonly, strong) NSString *base;
@property (nonatomic, nullable, strong) NSString *bodyString;
@property (nonatomic, nullable, strong) NSDictionary *headerFields;

- (nonnull id)initWithPath:(nonnull NSString *)path
                      base:(nullable NSString *)base;
@end

typedef void (^httpResponseHandler)(ATLHttpResponse *_Nonnull httpResponse);

@interface ATLNetworking : NSObject

- (void)sendPostRequestWithData:(nonnull ATLHttpRequest *)requestData
                        baseUrl:(nonnull NSURL *)baseUrl
                responseHandler:(nonnull httpResponseHandler)responseHandler;

@end
