//
//  MercuryPreloadMediaManager.h
//  MercurySDK
//
//  Created by CherryKing on 2020/2/27.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MercuryPreloadMediaInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryPreloadMediaManagerDelegate <NSObject>
/// 成功下载资源
- (void)preloadDownloadSourceSuccess:(NSURL *)url;

@end

@interface MercuryPreloadMediaManager : NSObject

@property (nonatomic, weak) id<MercuryPreloadMediaManagerDelegate> delegate;

/// 预缓存管理单例
+ (instancetype)manager;

/// 允许在移动网络下下载
@property (nonatomic, assign) BOOL downloadOnWWAN;

/// 预缓存媒体
- (void)saveInfoAndPreload:(MercuryPreloadMediaInfo *)mediaInfo;

/// 下载视频
- (void)downloadVideoUrlStr:(NSString *)urlStr;

@end

NS_ASSUME_NONNULL_END
