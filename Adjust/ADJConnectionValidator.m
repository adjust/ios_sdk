//
//  ADJConnectionValidator.m
//  Adjust
//
//  Created by Uglješa Erceg on 14/02/2017.
//  Copyright © 2017 adjust GmbH. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "ADJConnectionValidator.h"

@implementation ADJConnectionValidator

#pragma mark - Object lifecycle

- (id)init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    return self;
}

#pragma mark - NSURLSessionDelegate protocol

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    NSString *trustedThumbprint = @"5fb7ee0633e259dbad0c4c9ae6d38f1a61c7dc25";
    
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecTrustEvaluate(serverTrust, NULL);
    CFIndex count = SecTrustGetCertificateCount(serverTrust);
    
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, count - 1);
    CFDataRef certData = SecCertificateCopyData(certificate);
    
    NSData *data = (__bridge_transfer NSData *)certData;
    NSString *thumbprint = [self getThumbprintAsSha1:data];

    if ([[trustedThumbprint uppercaseString] isEqualToString:[thumbprint uppercaseString]]) {
        // tce = 0
        
        if (0 == self.expectedTce) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            
            _validationResult = YES;
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
            
            _validationResult = NO;
        }
    } else {
        // tce = 1++
        
        if (0 < self.expectedTce) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            
            _validationResult = YES;
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
            
            _validationResult = NO;
        }
    }

    // mark validation as done
    self.didValidationHappen = YES;
}

#pragma mark - Private & helper methods

- (NSString *)getThumbprintAsSha1:(NSData *)certData {
    unsigned char sha1Buffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(certData.bytes, (CC_LONG)certData.length, sha1Buffer);
    NSMutableString *fingerprint = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 3];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; ++i) {
        [fingerprint appendFormat:@"%02x",sha1Buffer[i]];
    }
    
    return [fingerprint stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
