//
//  BY_HCDataCacheItemZone.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/13.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCDataCacheItemZone.h"
#import "BY_HCData+Internal.h"

@implementation BY_HCDataCacheItemZone

- (instancetype)initWithOffset:(long long)offset length:(long long)length
{
    if (self = [super init]) {
        self->_offset = offset;
        self->_length = length;
    }
    return self;
}

@end
