//
//  BY_HCDataManager.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCDataReader.h"
#import "BY_HCDataLoader.h"
#import "BY_HCDataRequest.h"
#import "BY_HCDataResponse.h"
#import "BY_HCDataCacheItem.h"

@interface BY_HCDataStorage : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)storage;

/**
 *  Return file path if the content did finished cache.
 */
- (NSURL *)completeFileURLWithURL:(NSURL *)URL;

/**
 *  Reader for certain request.
 */
- (BY_HCDataReader *)readerWithRequest:(BY_HCDataRequest *)request;

/**
 *  Loader for certain request.
 */
- (BY_HCDataLoader *)loaderWithRequest:(BY_HCDataRequest *)request;

/**
 *  Get cache item.
 */
- (BY_HCDataCacheItem *)cacheItemWithURL:(NSURL *)URL;
- (NSArray<BY_HCDataCacheItem *> *)allCacheItems;

/**
 *  Get cache length.
 */
@property (nonatomic) long long maxCacheLength;     // Default is 500M.
- (long long)totalCacheLength;

/**
 *  Delete cache.
 */
- (void)deleteCacheWithURL:(NSURL *)URL;
- (void)deleteAllCaches;

@end
