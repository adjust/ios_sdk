//
//  ADJAttribution.m
//  adjust
//
//  Created by Pedro Filipe on 29/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJAttribution.h"
#import "ADJAdditions.h"

@implementation ADJAttribution

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    if ([ADJUtil isNull:jsonDict]) {
        return nil;
    }

    self.trackerToken = [jsonDict objectForKey:@"tracker_token"];
    self.trackerName = [jsonDict objectForKey:@"tracker_name"];
    self.network = [jsonDict objectForKey:@"network"];
    self.campaign = [jsonDict objectForKey:@"campaign"];
    self.adgroup = [jsonDict objectForKey:@"adgroup"];
    self.creative = [jsonDict objectForKey:@"creative"];
    self.clickLabel = [jsonDict objectForKey:@"click_label"];
    self.costType = [jsonDict objectForKey:@"cost_type"];
    self.costAmount = [jsonDict objectForKey:@"cost_amount"];
    self.costCurrency = [jsonDict objectForKey:@"cost_currency"];
    self.jsonResponse = jsonDict;

    return self;
}

- (BOOL)isEqualToAttribution:(ADJAttribution *)attribution {
    if (attribution == nil) {
        return NO;
    }
    if (![ADJAdditions adjIsStringEqual:self.trackerToken toString:attribution.trackerToken]) {
        return NO;
    }
    if (![ADJAdditions adjIsStringEqual:self.trackerName toString:attribution.trackerName]) {
        return NO;
    }
    if (![ADJAdditions adjIsStringEqual:self.network toString:attribution.network]) {
        return NO;
    }
    if (![ADJAdditions adjIsStringEqual:self.campaign toString:attribution.campaign]) {
        return NO;
    }
    if (![ADJAdditions adjIsStringEqual:self.adgroup toString:attribution.adgroup]) {
        return NO;
    }
    if (![ADJAdditions adjIsStringEqual:self.creative toString:attribution.creative]) {
        return NO;
    }
    if (![ADJAdditions adjIsStringEqual:self.clickLabel toString:attribution.clickLabel]) {
        return NO;
    }
    if (![ADJAdditions adjIsStringEqual:self.costType toString:attribution.costType]) {
        return NO;
    }
    if (![ADJAdditions adjIsNumberEqual:self.costAmount toNumber:attribution.costAmount]) {
        return NO;
    }
    if (![ADJAdditions adjIsStringEqual:self.costCurrency toString:attribution.costCurrency]) {
        return NO;
    }

    return YES;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *responseDataDic = [NSMutableDictionary dictionary];

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
    if (self.clickLabel != nil) {
        [responseDataDic setObject:self.clickLabel forKey:@"click_label"];
    }
    if (self.costType != nil) {
        [responseDataDic setObject:self.costType forKey:@"costType"];
    }
    if (self.costAmount != nil) {
        [responseDataDic setObject:[self.costAmount stringValue] forKey:@"costAmount"];
    }
    if (self.costCurrency != nil) {
        [responseDataDic setObject:self.costCurrency forKey:@"costCurrency"];
    }
    if (self.jsonResponse != nil) {
        [responseDataDic setObject:self.jsonResponse forKey:@"jsonResponse"];
    }

    return responseDataDic;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"tt:%@ tn:%@ net:%@ cam:%@ adg:%@ cre:%@ cl:%@ ct:%@ ca:%@ cc:%@",
            self.trackerToken, self.trackerName, self.network, self.campaign,
            self.adgroup, self.creative, self.clickLabel, self.costType,
            self.costAmount, self.costCurrency];
}


#pragma mark - NSObject
- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJAttribution class]]) {
        return NO;
    }

    return [self isEqualToAttribution:(ADJAttribution *)object];
}

- (NSUInteger)hash {
    return [self.trackerName hash];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ADJAttribution *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy.trackerToken = [self.trackerToken copyWithZone:zone];
        copy.trackerName = [self.trackerName copyWithZone:zone];
        copy.network = [self.network copyWithZone:zone];
        copy.campaign = [self.campaign copyWithZone:zone];
        copy.adgroup = [self.adgroup copyWithZone:zone];
        copy.creative = [self.creative copyWithZone:zone];
        copy.clickLabel = [self.clickLabel copyWithZone:zone];
        copy.costType = [self.costType copyWithZone:zone];
        copy.costAmount = [self.costAmount copyWithZone:zone];
        copy.costCurrency = [self.costCurrency copyWithZone:zone];
        copy.jsonResponse = [self.jsonResponse copyWithZone:zone];
    }

    return copy;
}


#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.trackerToken = [decoder decodeObjectOfClass:[NSString class] forKey:@"trackerToken"];
    self.trackerName = [decoder decodeObjectOfClass:[NSString class] forKey:@"trackerName"];
    self.network = [decoder decodeObjectOfClass:[NSString class] forKey:@"network"];
    self.campaign = [decoder decodeObjectOfClass:[NSString class] forKey:@"campaign"];
    self.adgroup = [decoder decodeObjectOfClass:[NSString class] forKey:@"adgroup"];
    self.creative = [decoder decodeObjectOfClass:[NSString class] forKey:@"creative"];
    self.clickLabel = [decoder decodeObjectOfClass:[NSString class] forKey:@"click_label"];
    self.costType = [decoder decodeObjectOfClass:[NSString class] forKey:@"costType"];
    self.costAmount = [decoder decodeObjectOfClass:[NSNumber class] forKey:@"costAmount"];
    self.costCurrency = [decoder decodeObjectOfClass:[NSString class] forKey:@"costCurrency"];
    NSSet<Class> *allowedClasses = [NSSet setWithObjects:[NSDictionary class],
                                    [NSString class], [NSNumber class], nil];
    self.jsonResponse = [decoder decodeObjectOfClasses:allowedClasses forKey:@"jsonResponse"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.trackerToken forKey:@"trackerToken"];
    [encoder encodeObject:self.trackerName forKey:@"trackerName"];
    [encoder encodeObject:self.network forKey:@"network"];
    [encoder encodeObject:self.campaign forKey:@"campaign"];
    [encoder encodeObject:self.adgroup forKey:@"adgroup"];
    [encoder encodeObject:self.creative forKey:@"creative"];
    [encoder encodeObject:self.clickLabel forKey:@"click_label"];
    [encoder encodeObject:self.costType forKey:@"costType"];
    [encoder encodeObject:self.costAmount forKey:@"costAmount"];
    [encoder encodeObject:self.costCurrency forKey:@"costCurrency"];
    [encoder encodeObject:self.jsonResponse forKey:@"jsonResponse"];
}

@end
