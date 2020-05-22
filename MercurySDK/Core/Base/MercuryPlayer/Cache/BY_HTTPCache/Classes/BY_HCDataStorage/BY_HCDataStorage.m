//
//  BY_HCDataManager.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCDataStorage.h"
#import "BY_HCData+Internal.h"
#import "BY_HCDataUnitPool.h"
#import "BY_HCLog.h"

@implementation BY_HCDataStorage

+ (instancetype)storage
{
    static BY_HCDataStorage *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.maxCacheLength = 500 * 1024 * 1024;
    }
    return self;
}

- (NSURL *)completeFileURLWithURL:(NSURL *)URL
{
    BY_HCDataUnit *unit = [[BY_HCDataUnitPool pool] unitWithURL:URL];
    NSURL *completeURL = unit.completeURL;
    [unit workingRelease];
    return completeURL;
}

- (BY_HCDataReader *)readerWithRequest:(BY_HCDataRequest *)request
{
    if (!request || request.URL.absoluteString.length <= 0) {
        BY_HCLogDataStorage(@"Invaild reader request, %@", request.URL);
        return nil;
    }
    BY_HCDataReader *reader = [[BY_HCDataReader alloc] initWithRequest:request];
    return reader;
}

- (BY_HCDataLoader *)loaderWithRequest:(BY_HCDataRequest *)request
{
    if (!request || request.URL.absoluteString.length <= 0) {
        BY_HCLogDataStorage(@"Invaild loader request, %@", request.URL);
        return nil;
    }
    BY_HCDataLoader *loader = [[BY_HCDataLoader alloc] initWithRequest:request];
    return loader;
}

- (BY_HCDataCacheItem *)cacheItemWithURL:(NSURL *)URL
{
    return [[BY_HCDataUnitPool pool] cacheItemWithURL:URL];
}

- (NSArray<BY_HCDataCacheItem *> *)allCacheItems
{
    return [[BY_HCDataUnitPool pool] allCacheItem];
}

- (long long)totalCacheLength
{
    return [[BY_HCDataUnitPool pool] totalCacheLength];
}

- (void)deleteCacheWithURL:(NSURL *)URL
{
    [[BY_HCDataUnitPool pool] deleteUnitWithURL:URL];
}

- (void)deleteAllCaches
{
    [[BY_HCDataUnitPool pool] deleteAllUnits];
}

@end
