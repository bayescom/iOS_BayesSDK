//
//  BY_HTTPCache.m
//  BY_HTTPCache
//
//  Created by Single on 2017/8/13.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HTTPCache.h"
#import "BY_HCDataStorage.h"
#import "BY_HCHTTPServer.h"
#import "BY_HCDownload.h"
#import "BY_HCURLTool.h"
#import "BY_HCLog.h"

@implementation BY_HTTPCache

#pragma mark - HTTP Server

+ (BOOL)proxyStart:(NSError **)error
{
    return [[BY_HCHTTPServer server] start:error];
}

+ (void)proxyStop
{
    [[BY_HCHTTPServer server] stop];
}

+ (BOOL)proxyIsRunning
{
    return [BY_HCHTTPServer server].isRunning;
}

+ (NSURL *)proxyURLWithOriginalURL:(NSURL *)URL
{
    return [[BY_HCHTTPServer server] URLWithOriginalURL:URL];
}

#pragma mark - Data Storage

+ (NSURL *)cacheCompleteFileURLWithURL:(NSURL *)URL
{
    return [[BY_HCDataStorage storage] completeFileURLWithURL:URL];
}

+ (BY_HCDataReader *)cacheReaderWithRequest:(BY_HCDataRequest *)request
{
    return [[BY_HCDataStorage storage] readerWithRequest:request];
}

+ (BY_HCDataLoader *)cacheLoaderWithRequest:(BY_HCDataRequest *)request
{
    return [[BY_HCDataStorage storage] loaderWithRequest:request];
}

+ (void)cacheSetMaxCacheLength:(long long)maxCacheLength
{
    [BY_HCDataStorage storage].maxCacheLength = maxCacheLength;
}

+ (long long)cacheMaxCacheLength
{
    return [BY_HCDataStorage storage].maxCacheLength;
}

+ (long long)cacheTotalCacheLength
{
    return [BY_HCDataStorage storage].totalCacheLength;
}

+ (BY_HCDataCacheItem *)cacheCacheItemWithURL:(NSURL *)URL
{
    return [[BY_HCDataStorage storage] cacheItemWithURL:URL];
}

+ (NSArray<BY_HCDataCacheItem *> *)cacheAllCacheItems
{
    return [[BY_HCDataStorage storage] allCacheItems];
}

+ (void)cacheDeleteCacheWithURL:(NSURL *)URL
{
    [[BY_HCDataStorage storage] deleteCacheWithURL:URL];
}

+ (void)cacheDeleteAllCaches
{
    [[BY_HCDataStorage storage] deleteAllCaches];
}

#pragma mark - Encode

+ (void)encodeSetURLConverter:(NSURL * (^)(NSURL *URL))URLConverter;
{
    [BY_HCURLTool tool].URLConverter = URLConverter;
}

#pragma mark - Download

+ (void)downloadSetTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    [BY_HCDownload download].timeoutInterval = timeoutInterval;
}

+ (NSTimeInterval)downloadTimeoutInterval
{
    return [BY_HCDownload download].timeoutInterval;
}

+ (void)downloadSetWhitelistHeaderKeys:(NSArray<NSString *> *)whitelistHeaderKeys
{
    [BY_HCDownload download].whitelistHeaderKeys = whitelistHeaderKeys;
}

+ (NSArray<NSString *> *)downloadWhitelistHeaderKeys
{
    return [BY_HCDownload download].whitelistHeaderKeys;
}

+ (void)downloadSetAdditionalHeaders:(NSDictionary<NSString *, NSString *> *)additionalHeaders
{
    [BY_HCDownload download].additionalHeaders = additionalHeaders;
}

+ (NSDictionary<NSString *, NSString *> *)downloadAdditionalHeaders
{
    return [BY_HCDownload download].additionalHeaders;
}

+ (void)downloadSetAcceptableContentTypes:(NSArray<NSString *> *)acceptableContentTypes
{
    [BY_HCDownload download].acceptableContentTypes = acceptableContentTypes;
}

+ (NSArray<NSString *> *)downloadAcceptableContentTypes
{
    return [BY_HCDownload download].acceptableContentTypes;
}

+ (void)downloadSetUnacceptableContentTypeDisposer:(BOOL(^)(NSURL *URL, NSString *contentType))unacceptableContentTypeDisposer
{
    [BY_HCDownload download].unacceptableContentTypeDisposer = unacceptableContentTypeDisposer;
}

#pragma mark - Log

+ (void)logAddLog:(NSString *)log
{
    if (log.length > 0) {
        BY_HCLogCommon(@"%@", log);
    }
}

+ (void)logSetConsoleLogEnable:(BOOL)consoleLogEnable
{
    [BY_HCLog log].consoleLogEnable = consoleLogEnable;
}

+ (BOOL)logConsoleLogEnable
{
    return [BY_HCLog log].consoleLogEnable;
}

+ (BOOL)logRecordLogEnable
{
    return [BY_HCLog log].recordLogEnable;
}

+ (NSURL *)logRecordLogFileURL
{
    return [BY_HCLog log].recordLogFileURL;
}

+ (void)logSetRecordLogEnable:(BOOL)recordLogEnable
{
    [BY_HCLog log].recordLogEnable = recordLogEnable;
}

+ (void)logDeleteRecordLogFile
{
    [[BY_HCLog log] deleteRecordLogFile];
}

+ (NSDictionary<NSURL *, NSError *> *)logErrors
{
    return [[BY_HCLog log] errors];
}

+ (void)logCleanErrorForURL:(NSURL *)URL
{
    [[BY_HCLog log] cleanErrorForURL:URL];
}

+ (NSError *)logErrorForURL:(NSURL *)URL
{
    return [[BY_HCLog log] errorForURL:URL];
}

@end
