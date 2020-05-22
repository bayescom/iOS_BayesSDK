//
//  BY_HCRange.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2018/5/20.
//  Copyright © 2018年 Single. All rights reserved.
//

#import "BY_HCRange.h"

BOOL BY_HCRangeIsFull(BY_HCRange range)
{
    return BY_HCEqualRanges(range, BY_HCRangeFull());
}

BOOL BY_HCRangeIsVaild(BY_HCRange range)
{
    return !BY_HCRangeIsInvaild(range);
}

BOOL BY_HCRangeIsInvaild(BY_HCRange range)
{
    return BY_HCEqualRanges(range, BY_HCRangeInvaild());
}

BOOL BY_HCEqualRanges(BY_HCRange range1, BY_HCRange range2)
{
    return range1.start == range2.start && range1.end == range2.end;
}

long long BY_HCRangeGetLength(BY_HCRange range)
{
    if (range.start == BY_HCNotFound || range.end == BY_HCNotFound) {
        return BY_HCNotFound;
    }
    return range.end - range.start + 1;
}

NSString *BY_HCStringFromRange(BY_HCRange range)
{
    return [NSString stringWithFormat:@"Range : {%lld, %lld}", range.start, range.end];
}

NSString *BY_HCRangeGetHeaderString(BY_HCRange range)
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"bytes="];
    if (range.start != BY_HCNotFound) {
        [string appendFormat:@"%lld", range.start];
    }
    [string appendFormat:@"-"];
    if (range.end != BY_HCNotFound) {
        [string appendFormat:@"%lld", range.end];
    }
    return [string copy];
}

NSDictionary *BY_HCRangeFillToRequestHeaders(BY_HCRange range, NSDictionary *headers)
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary:headers];
    [ret setObject:BY_HCRangeGetHeaderString(range) forKey:@"Range"];
    return ret;
}

NSDictionary *BY_HCRangeFillToRequestHeadersIfNeeded(BY_HCRange range, NSDictionary *headers)
{
    if ([headers objectForKey:@"Range"]) {
        return headers;
    }
    return BY_HCRangeFillToRequestHeaders(range, headers);
}

NSDictionary *BY_HCRangeFillToResponseHeaders(BY_HCRange range, NSDictionary *headers, long long totalLength)
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary:headers];
    long long currentLength = BY_HCRangeGetLength(range);
    [ret setObject:[NSString stringWithFormat:@"%lld", currentLength] forKey:@"Content-Length"];
    [ret setObject:[NSString stringWithFormat:@"bytes %lld-%lld/%lld", range.start, range.end, totalLength] forKey:@"Content-Range"];
    return ret;
}

BY_HCRange BY_HCMakeRange(long long start, long long end)
{
    BY_HCRange range = {start, end};
    return range;
}

BY_HCRange BY_HCRangeZero(void)
{
    return BY_HCMakeRange(0, 0);
}

BY_HCRange BY_HCRangeFull(void)
{
    return BY_HCMakeRange(0, BY_HCNotFound);
}

BY_HCRange BY_HCRangeInvaild()
{
    return BY_HCMakeRange(BY_HCNotFound, BY_HCNotFound);
}

BY_HCRange BY_HCRangeWithSeparateValue(NSString *value)
{
    BY_HCRange range = BY_HCRangeInvaild();
    if (value.length > 0) {
        NSArray *components = [value componentsSeparatedByString:@","];
        if (components.count == 1) {
            components = [components.firstObject componentsSeparatedByString:@"-"];
            if (components.count == 2) {
                NSString *startString = [components objectAtIndex:0];
                NSInteger startValue = [startString integerValue];
                NSString *endString = [components objectAtIndex:1];
                NSInteger endValue = [endString integerValue];
                if (startString.length && (startValue >= 0) && endString.length && (endValue >= startValue)) {
                    // The second 500 bytes: "500-999"
                    range.start = startValue;
                    range.end = endValue;
                } else if (startString.length && (startValue >= 0)) {
                    // The bytes after 9500 bytes: "9500-"
                    range.start = startValue;
                    range.end = BY_HCNotFound;
                } else if (endString.length && (endValue > 0)) {
                    // The final 500 bytes: "-500"
                    range.start = BY_HCNotFound;
                    range.end = endValue;
                }
            }
        }
    }
    return range;
}

BY_HCRange BY_HCRangeWithRequestHeaderValue(NSString *value)
{
    if ([value hasPrefix:@"bytes="]) {
        NSString *rangeString = [value substringFromIndex:6];
        return BY_HCRangeWithSeparateValue(rangeString);
    }
    return BY_HCRangeInvaild();
}

BY_HCRange BY_HCRangeWithResponseHeaderValue(NSString *value, long long *totalLength)
{
    if ([value hasPrefix:@"bytes "]) {
        value = [value stringByReplacingOccurrencesOfString:@"bytes " withString:@""];
        NSRange range = [value rangeOfString:@"/"];
        if (range.location != NSNotFound) {
            NSString *rangeString = [value substringToIndex:range.location];
            NSString *totalLengthString = [value substringFromIndex:range.location + range.length];
            *totalLength = totalLengthString.longLongValue;
            return BY_HCRangeWithSeparateValue(rangeString);
        }
    }
    return BY_HCRangeInvaild();
}

BY_HCRange BY_HCRangeWithEnsureLength(BY_HCRange range, long long ensureLength)
{
    if (range.end == BY_HCNotFound && ensureLength > 0) {
        return BY_HCMakeRange(range.start, ensureLength - 1);
    }
    return range;
}
