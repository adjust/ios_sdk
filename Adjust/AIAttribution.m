//
//  AIAttribution.m
//  adjust
//
//  Created by Pedro Filipe on 29/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AIAttribution.h"

@implementation AIAttribution

- (BOOL)isEqualToAttribution:(AIAttribution *)attribution {
    if (attribution == nil) {
        return NO;
    }
    if (![self.trackerToken isEqualToString:attribution.trackerToken]) {
        return NO;
    }
    if (![self.trackerName isEqualToString:attribution.trackerName]) {
        return NO;
    }
    if (![self.network isEqualToString:attribution.network]) {
        return NO;
    }
    if (![self.campaign isEqualToString:attribution.campaign]) {
        return NO;
    }
    if (![self.adgroup isEqualToString:attribution.adgroup]) {
        return NO;
    }
    if (![self.creative isEqualToString:attribution.creative]) {
        return NO;
    }
    return YES;
}

+ (AIAttribution *)dataWithJsonDict:(NSDictionary *)jsonDict {
    return [[AIAttribution alloc] initWithJsonDict:jsonDict];
}

- (id)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self == nil) return nil;

    if (jsonDict == nil) {
        return nil;
    }

    self.trackerToken = [jsonDict objectForKey:@"tracker_token"];
    self.trackerName  = [jsonDict objectForKey:@"tracker_name"];
    self.network      = [jsonDict objectForKey:@"network"];
    self.campaign     = [jsonDict objectForKey:@"campaign"];
    self.adgroup      = [jsonDict objectForKey:@"adgroup"];
    self.creative     = [jsonDict objectForKey:@"creative"];

    return self;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary * responseDataDic = [NSMutableDictionary dictionary];

    if (self.trackerToken != nil) {
        [responseDataDic setObject:self.trackerToken forKey:@"trackerToken"];
    }

    if (self.trackerName != nil) {
        [responseDataDic setObject:self.trackerName forKey:@"trackerName"];
    }

    if (self.network != nil) {
        [responseDataDic setObject:self.network forKey:@"network"];
    }
    
    if (self.campaign != nil) {
        [responseDataDic setObject:self.campaign forKey:@"campaign"];
    }
    
    if (self.adgroup != nil) {
        [responseDataDic setObject:self.adgroup forKey:@"adgroup"];
    }
    
    if (self.creative != nil) {
        [responseDataDic setObject:self.creative forKey:@"creative"];
    }
    
    return responseDataDic;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"tt:%@ tn:%@ net:%@ cam:%@ adg:%@ cre:%@",
            self.trackerToken, self.trackerName, self.network, self.campaign,
            self.adgroup, self.campaign];
}


#pragma mark - NSObject
- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[AIAttribution class]]) {
        return NO;
    }

    return [self isEqualToAttribution:(AIAttribution *)object];
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + [self.trackerToken hash];
    result = prime * result + [self.trackerName hash];
    result = prime * result + [self.network hash];
    result = prime * result + [self.campaign hash];
    result = prime * result + [self.adgroup hash];
    result = prime * result + [self.creative hash];

    return result;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) return nil;

    self.trackerToken = [decoder decodeObjectForKey:@"trackerToken"];
    self.trackerName  = [decoder decodeObjectForKey:@"trackerName"];
    self.network      = [decoder decodeObjectForKey:@"network"];
    self.campaign     = [decoder decodeObjectForKey:@"campaign"];
    self.adgroup      = [decoder decodeObjectForKey:@"adgroup"];
    self.creative     = [decoder decodeObjectForKey:@"creative"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.trackerToken forKey:@"trackerToken"];
    [encoder encodeObject:self.trackerName  forKey:@"trackerName"];
    [encoder encodeObject:self.network      forKey:@"network"];
    [encoder encodeObject:self.campaign     forKey:@"campaign"];
    [encoder encodeObject:self.adgroup      forKey:@"adgroup"];
    [encoder encodeObject:self.creative     forKey:@"creative"];
}


@end
