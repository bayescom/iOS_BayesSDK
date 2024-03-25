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

/// 选择是否开启日志打印
/// @param enable 是否打印日志，默认为YES
+ (void)openDebug:(BOOL)enable;

/// 获取 SDK 版本
+ (NSString *)sdkVersion;

/// 预缓存素材资源
+ (void)preloadResources;

/// 设置标准UA
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

/// 禁止SDK获取IDFA信息，默认值为NO：即允许获取
+ (void)forbiddenIDFA:(BOOL)forbidden;


#pragma mark: - Location

/// 禁止SDK获取位置信息，默认值为NO：即允许获取
+ (void)forbiddenLocation:(BOOL)forbidden;

/// 当用户禁止SDK获取位置信息时，可自行传入位置信息
/// @param latitude 实时的地理位置纬度
/// @param longitude 实时的地理位置经度
+ (void)setUserLocationLatitude:(NSString *)latitude longitude:(NSString *)longitude;

@end

NS_ASSUME_NONNULL_END
