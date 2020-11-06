//
//  MercuryConfigManager.h
//  BayesSDK
//
//  Created by CherryKing on 2019/11/4.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: ======================= 配置信息Key =======================
FOUNDATION_EXPORT NSString * const kMercuryConfigIdfaAuth;

@interface MercuryConfigManager : NSObject

/// 设置AppID
/// @param appID 应用的AppID
/// @param mediaKey 媒体Key
+ (void)setAppID:(NSString *)appID mediaKey:(NSString *)mediaKey;

/// 设置AppID
/// @param appID 应用的AppID
/// @param mediaKey 媒体Key
/// @param config 配置信息
+ (void)setAppID:(NSString *)appID mediaKey:(NSString *)mediaKey config:(NSDictionary *)config;

/// 选择是否开启日志打印
/// @param isDebug 是否打印日志
+ (void)openDebug:(BOOL)isDebug;

/// 获取 SDK 版本
+ (NSString *)sdkVersion;

/// 是否需要预缓存资源
+ (void)preloadedResourcesIfNeed:(BOOL)isNeed;

+ (void)setDefaultUserAgent:(NSString *)ua;

@end

NS_ASSUME_NONNULL_END
