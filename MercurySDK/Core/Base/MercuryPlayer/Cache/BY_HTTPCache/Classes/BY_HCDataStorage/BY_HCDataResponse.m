//
//  BY_HCDataResponse.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/24.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCDataResponse.h"
#import "BY_HCData+Internal.h"
#import "BY_HCLog.h"

@implementation BY_HCDataResponse

- (instancetype)initWithURL:(NSURL *)URL headers:(NSDictionary *)headers
{
    if (self = [super init]) {
        BY_HCLogAlloc(self);
        self->_URL = URL;
        self->_headers = headers;
        self->_contentType = [self headerValueWithKey:@"Content-Type"];
        self->_contentRangeString = [self headerValueWithKey:@"Content-Range"];
        self->_contentLength = [self headerValueWithKey:@"Content-Length"].longLongValue;
        self->_contentRange = BY_HCRangeWithResponseHeaderValue(self.contentRangeString, &self->_totalLength);
        BY_HCLogDataResponse(@"%p Create data response\nURL : %@\nHeaders : %@\ncontentType : %@\ntotalLength : %lld\ncurrentLength : %lld", self, self.URL, self.headers, self.contentType, self.totalLength, self.contentLength);
    }
    return self;
}

- (void)dealloc
{
    BY_HCLogDealloc(self);
}

- (NSString *)headerValueWithKey:(NSString *)key
{
    NSString *value = [self.headers objectForKey:key];
    if (!value) {
        value = [self.headers objectForKey:[key lowercaseString]];
    }
    return value;
}

@end
