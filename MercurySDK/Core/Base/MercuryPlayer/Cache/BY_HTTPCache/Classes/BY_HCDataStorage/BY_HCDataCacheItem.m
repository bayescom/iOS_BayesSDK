//
//  BY_HCDataCacheItem.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/13.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCDataCacheItem.h"
#import "BY_HCData+Internal.h"

@implementation BY_HCDataCacheItem

- (instancetype)initWithURL:(NSURL *)URL
                      zones:(NSArray<BY_HCDataCacheItemZone *> *)zones
                totalLength:(long long)totalLength
                cacheLength:(long long)cacheLength
                vaildLength:(long long)vaildLength
{
    if (self = [super init]) {
        self->_URL = [URL copy];
        self->_zones = [zones copy];
        self->_totalLength = totalLength;
        self->_cacheLength = cacheLength;
        self->_vaildLength = vaildLength;
    }
    return self;
}

@end
