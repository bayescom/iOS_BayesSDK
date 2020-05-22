//
//  BY_HCDataUnitPool.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCDataUnit.h"
#import "BY_HCDataCacheItem.h"

@interface BY_HCDataUnitPool : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)pool;

- (BY_HCDataUnit *)unitWithURL:(NSURL *)URL;

- (long long)totalCacheLength;

- (NSArray<BY_HCDataCacheItem *> *)allCacheItem;
- (BY_HCDataCacheItem *)cacheItemWithURL:(NSURL *)URL;

- (void)deleteUnitWithURL:(NSURL *)URL;
- (void)deleteUnitsWithLength:(long long)length;
- (void)deleteAllUnits;

@end
