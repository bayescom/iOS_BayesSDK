//
//  BY_HCDataRequest.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCDataRequest.h"
#import "BY_HCData+Internal.h"
#import "BY_HCLog.h"

@implementation BY_HCDataRequest

- (instancetype)initWithURL:(NSURL *)URL headers:(NSDictionary *)headers
{
    if (self = [super init]) {
        BY_HCLogAlloc(self);
        self->_URL = URL;
        self->_headers = BY_HCRangeFillToRequestHeadersIfNeeded(BY_HCRangeFull(), headers);
        self->_range = BY_HCRangeWithRequestHeaderValue([self.headers objectForKey:@"Range"]);
        BY_HCLogDataRequest(@"%p Create data request\nURL : %@\nHeaders : %@\nRange : %@", self, self.URL, self.headers, BY_HCStringFromRange(self.range));
    }
    return self;
}

- (void)dealloc
{
    BY_HCLogDealloc(self);
}

- (BY_HCDataRequest *)newRequestWithRange:(BY_HCRange)range
{
    NSDictionary *headers = BY_HCRangeFillToRequestHeaders(range, self.headers);
    BY_HCDataRequest *obj = [[BY_HCDataRequest alloc] initWithURL:self.URL headers:headers];
    return obj;
}

- (BY_HCDataRequest *)newRequestWithTotalLength:(long long)totalLength
{
    BY_HCRange range = BY_HCRangeWithEnsureLength(self.range, totalLength);
    return [self newRequestWithRange:range];
}

@end
