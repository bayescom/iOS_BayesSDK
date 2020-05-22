//
//  BY_HCRange.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2018/5/20.
//  Copyright © 2018年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct BY_HCRange {
    long long start;
    long long end;
} BY_HCRange;

static const long long BY_HCNotFound = LONG_LONG_MAX;

BOOL BY_HCRangeIsFull(BY_HCRange range);
BOOL BY_HCRangeIsVaild(BY_HCRange range);
BOOL BY_HCRangeIsInvaild(BY_HCRange range);
BOOL BY_HCEqualRanges(BY_HCRange range1, BY_HCRange range2);
long long BY_HCRangeGetLength(BY_HCRange range);
NSString * BY_HCStringFromRange(BY_HCRange range);
NSDictionary * BY_HCRangeFillToRequestHeaders(BY_HCRange range, NSDictionary *eaders);
NSDictionary * BY_HCRangeFillToRequestHeadersIfNeeded(BY_HCRange range, NSDictionary *headers);
NSDictionary * BY_HCRangeFillToResponseHeaders(BY_HCRange range, NSDictionary *headers, long long totalLength);

BY_HCRange BY_HCMakeRange(long long start, long long end);
BY_HCRange BY_HCRangeZero(void);
BY_HCRange BY_HCRangeFull(void);
BY_HCRange BY_HCRangeInvaild(void);
BY_HCRange BY_HCRangeWithSeparateValue(NSString *value);
BY_HCRange BY_HCRangeWithRequestHeaderValue(NSString *value);
BY_HCRange BY_HCRangeWithResponseHeaderValue(NSString *value, long long *totalLength);
BY_HCRange BY_HCRangeWithEnsureLength(BY_HCRange range, long long ensureLength);
