//
//  MercuryPreloadMediaManager.m
//  MercurySDK
//
//  Created by CherryKing on 2020/2/27.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "MercuryPreloadMediaManager.h"

#import "MercuryPreloadMediaInfo.h"
#import "MercuryLog.h"
#import "SDWebImagePrefetcher.h"
#import "SDImageCache.h"
#import "BY_HTTPCache.h"
#import "MercuryReachability.h"

@interface MercuryPreloadMediaManager () <BY_HCDataLoaderDelegate>
/// 视频下载器
@property (nonatomic, strong) BY_HCDataLoader *dataLoader;
/// 预下载的资源
@property (nonatomic, strong) MercuryPreloadMediaInfo *mediaInfo;
/// 视频资源
@property (nonatomic, strong) NSMutableArray<MercuryPreloadMediaInfoItem *> *videoArrM;
/// 图片资源
@property (nonatomic, strong) NSMutableArray<NSString *> *imgArrM;
/// 网络监听
@property (nonatomic, strong) MercuryReachability *reachability;

@end

@implementation MercuryPreloadMediaManager

static MercuryPreloadMediaManager *_instance = nil;
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
        _instance.videoArrM = [NSMutableArray array];
        _instance.imgArrM = [NSMutableArray array];
        // 监听网络环境
        if (!_instance.reachability) {
            _instance.reachability = [MercuryReachability reachabilityForInternetConnection];
            [_instance.reachability setReachableBlock:^(MercuryReachability *reachability) {
                [_instance beginDownloadIfWifi];
            }];
        }
    }) ;
    return _instance ;
}

// MARK: ======================= private =======================
- (void)saveInfoAndPreload:(MercuryPreloadMediaInfo *)mediaInfo {
    _mediaInfo = mediaInfo;
    
    // 开启服务器
    NSError *error;
    if (![BY_HTTPCache proxyIsRunning]) {
        [BY_HTTPCache proxyStart:&error];
    }
//    [BY_HTTPCache cacheDeleteAllCaches];
    if (error) { MercuryLog(@"%@", error); }
    // 构建下载数组
    for (MercuryPreloadMediaInfoItem *item in mediaInfo.urls) {
        if (item.isVideo) {
            [_videoArrM addObject:item];
        } else {
            [_imgArrM addObject:item.url];
        }
    }
    // 开始下载
    [self beginDownloadIfWifi];
}

- (void)removeExpiredResource {
    // 删除过期图片
    for (NSString *imgUrl in _imgArrM) {
        [[SDImageCache sharedImageCache] removeImageForKey:imgUrl fromDisk:YES withCompletion:^{
            MercuryLog(@"删除过期图片: %@", imgUrl);
        }];
    }
    // 删除过期视频
    for (MercuryPreloadMediaInfoItem *videoItem in _videoArrM) {
        [BY_HTTPCache cacheDeleteCacheWithURL:[NSURL URLWithString:videoItem.url]];
        MercuryLog(@"删除过期视频: %@", videoItem.url);
    }
}

/// 如果是Wifi环境，开始下载资源
- (void)beginDownloadIfWifi {
    // 检测网络环境 Wifi下才开始下载
    if (!_reachability.isReachableViaWiFi) {
        // 非Wifi直接return
        return;
    }
    // 下载图片
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:[_imgArrM copy] progress:nil completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
        MercuryLog(@"%@", [NSString stringWithFormat:@"预缓存图片: 未完成: %lu | 已完成: %lu",(unsigned long)noOfSkippedUrls, (unsigned long)noOfFinishedUrls]);
        if (noOfSkippedUrls == 0) { // 没有未完成的下载项
            [self.imgArrM removeAllObjects];
            [self removeObserverIfNeed];
        }
    }];
    // 下载视频
    if (_videoArrM.count > 0) {
        [self beginVideoDownload:[NSURL URLWithString:_videoArrM.firstObject.url]];
    }
}

- (void)downloadVideoUrlStr:(NSString *)urlStr {
    MercuryPreloadMediaInfoItem *item = [[MercuryPreloadMediaInfoItem alloc] init];
    item.url = urlStr;
    item.fileType = @"mp4";
    [_videoArrM addObject:item];
    // 下载视频
    if (_videoArrM.count > 0) {
        [self beginVideoDownload:[NSURL URLWithString:_videoArrM.firstObject.url]];
    }
}

/// 当下载的资源数组都为空，释放监听
- (void)removeObserverIfNeed {
    if (_videoArrM.count <= 0 && _imgArrM.count <= 0) {
    }
}

- (void)beginVideoDownload:(NSURL *)videoUrl {
    // 检测网络环境 Wifi下才开始下载
    if (!_downloadOnWWAN && !_reachability.isReachableViaWiFi) {
        // 非Wifi直接return
        return;
    }
    
    // 下载视频
    _dataLoader = [BY_HTTPCache cacheLoaderWithRequest:[[BY_HCDataRequest alloc] initWithURL:videoUrl headers:nil]];
    _dataLoader.delegate = self;
    [_dataLoader prepare];
}

// MARK: ======================= 网络变化 =======================
- (void)reachabilityChanged:(NSNotification *)noti {
    [self beginDownloadIfWifi];
}

// MARK: ======================= BY_HCDataLoaderDelegate =======================
- (void)ktv_loaderDidFinish:(BY_HCDataLoader *)loader {
    MercuryLog(@"%@", [NSString stringWithFormat:@"视频预下载成功(%@)", loader.request.URL.absoluteURL]);
    // 下载完成移除下载好的，开始下载下一个
    if (_videoArrM.count > 0) {
        [_videoArrM removeObjectAtIndex:0];
        [self beginVideoDownload:[NSURL URLWithString:_videoArrM.firstObject.url]];
        if ([_delegate respondsToSelector:@selector(preloadDownloadSourceSuccess:)]) {
            [_delegate preloadDownloadSourceSuccess:loader.request.URL.absoluteURL];
        }
    } else {
        _dataLoader = nil;
        [self removeObserverIfNeed];
    }
}

- (void)ktv_loader:(BY_HCDataLoader *)loader didFailWithError:(NSError *)error {
    MercuryLog(@"%@", [NSString stringWithFormat:@"视频预下载失败(%@):%@", loader.request.URL.absoluteURL, error]);
}

- (void)ktv_loader:(BY_HCDataLoader *)loader didChangeProgress:(double)progress {}

// 获取当前时间戳
- (NSString *)getCurrentTimestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; // 获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970]*1000;// *1000 是精确到毫秒(13位),不乘就是精确到秒(10位)
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

@end
