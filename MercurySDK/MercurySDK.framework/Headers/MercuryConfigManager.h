//
//  MercuryConfigManager.h
//  MercurySDK
//
//  Created by Bayes on 2019/11/4.
//  Copyright © 2019 Bayes.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MercuryConfigManager : NSObject

/// 设置AppID
/// @param appID 应用的AppID
/// @param appKey 媒体Key
+ (void)setAppID:(NSString *)appID appKey:(NSString *)appKey;

/// 设置AppID
/// @param appID 应用的AppID
/// @param appKey 媒体Key
/// @param config 配置信息 如果SDK集成者自己申请CAID 请将其放入config里面
+ (void)setAppID:(NSString *)appID appKey:(NSString *)appKey config:(nullable NSDictionary *)config;

/// 选择是否开启日志打印
/// @param enable 是否打印日志，默认为YES
+ (void)openDebug:(BOOL)enable;

/// 获取 SDK 版本
+ (NSString *)sdkVersion;

/// 是否需要预缓存资源
+ (void)preloadedResourcesIfNeed:(BOOL)isNeed;

/// 设置ua
/// 联调时发现ua不符合规范 可用此方法传入ua 此处需传原始ua
/// 需在初始化时 调用该方法
+ (void)setDefaultUserAgent:(NSString *)ua;

/// 是否需要支持HTTPS  默认不需要
+ (void)supportHttps:(BOOL)isNeed;

/// 是否允许个性化广告推送 默认为允许
+ (void)openAdTrack:(BOOL)open;

/// 设置AAID
/// - Parameters:
///   - mediaId: 阿里提供给媒体的mediaId
///   - mediaSecret: 阿里提供给媒体的mediaSecret
+ (void)setAAIDWithMediaId:(NSString *)mediaId mediaSecret:(NSString *)mediaSecret;

/// 禁止倍业SDK获取IDFA信息，默认值为NO：即允许获取
+ (void)forbiddenIDFA:(BOOL)forbidden;


@end

NS_ASSUME_NONNULL_END
