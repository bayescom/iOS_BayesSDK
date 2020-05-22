//
//  BY_HCData+Internal.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCDataCacheItemZone.h"
#import "BY_HCDataCacheItem.h"
#import "BY_HCDataResponse.h"
#import "BY_HCDataRequest.h"
#import "BY_HCDataReader.h"
#import "BY_HCDataLoader.h"

#pragma mark - BY_HCDataReader

@interface BY_HCDataReader ()

- (instancetype)initWithRequest:(BY_HCDataRequest *)request NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - BY_HCDataLoader

@interface BY_HCDataLoader ()

- (instancetype)initWithRequest:(BY_HCDataRequest *)request NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - BY_HCDataRequest

@interface BY_HCDataRequest ()

- (BY_HCDataRequest *)newRequestWithRange:(BY_HCRange)range;
- (BY_HCDataRequest *)newRequestWithTotalLength:(long long)totalLength;

@end

#pragma mark - BY_HCDataResponse

@interface BY_HCDataResponse ()

- (instancetype)initWithURL:(NSURL *)URL headers:(NSDictionary *)headers NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - BY_HCDataCacheItem

@interface BY_HCDataCacheItem ()

- (instancetype)initWithURL:(NSURL *)URL
                      zones:(NSArray<BY_HCDataCacheItemZone *> *)zones
                totalLength:(long long)totalLength
                cacheLength:(long long)cacheLength
                vaildLength:(long long)vaildLength NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - BY_HCDataCacheItemZone

@interface BY_HCDataCacheItemZone ()

- (instancetype)initWithOffset:(long long)offset length:(long long)length NS_DESIGNATED_INITIALIZER;

@end
