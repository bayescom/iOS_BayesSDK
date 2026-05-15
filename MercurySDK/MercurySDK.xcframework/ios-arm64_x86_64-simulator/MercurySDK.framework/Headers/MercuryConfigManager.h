//
//  MercuryConfigManager.h
//  MercurySDK
//
//  Created by YAO on 2019/11/4.
//  Copyright © 2019 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MercuryConfigManager : NSObject

/// 设置AppID
/// @param appID 应用的AppID
/// @param appKey 媒体Key
+ (void)setAppID:(NSString *)appID appKey:(NSString *)appKey __attribute__((deprecated("接口即将废弃，请使用initWithAppId:appKey和startWithCompletionHandler新接口")));

/// SDK初始化
/// @param appId 应用Id
/// @param appKey 应用Key
/// @note 调用initWithAppId:appKey接口后，请尽快调用startWithCompletionHandler接口；否则会影响SDK功能。
+ (void)initWithAppId:(NSString *)appId appKey:(NSString *)appKey;

/// 启动SDK
/// @param handler 启动成功/失败的结果回调
/// @note 请先调用initWithAppId:appKey接口，再调用startWithCompletionHandler接口。
+ (void)startWithCompletionHandler:(void(^)(BOOL success, NSError *error))handler;

/// 选择是否开启日志打印
/// @param enable 是否打印日志，默认为YES
+ (void)openDebug:(BOOL)enable;

/// 获取 SDK 版本
+ (NSString *)sdkVersion;

/// 预缓存素材资源
+ (void)preloadResources __attribute__((deprecated("接口已废弃，改为SDK获取配置后内部执行")));

/// 设置标准UA
+ (void)setDefaultUserAgent:(NSString *)ua;

/// 自定义广告角标
+ (void)setCustomLogoImage:(UIImage *)logo;

/// 是否需要支持HTTPS  默认不需要
+ (void)supportHttps:(BOOL)isNeed;

/// 是否允许个性化广告推送 默认为允许
+ (void)openAdTrack:(BOOL)enable;

/// 设置ID
/// - Parameters:
///   - identity: cid值
///   - version: cid版本号
/// - note: cid支持传入多个不同版本，开发者可多次调用此方法
+ (void)setID:(NSString *)identity version:(NSString *)version;

/// 禁止SDK获取IDFA信息，默认值为NO：即允许获取
+ (void)forbiddenIDFA:(BOOL)forbidden;

/// 禁止SDK使用加速度传感器，默认值为NO：即允许使用
/// 传入YES将限制摇一摇等交互能力
+ (void)forbiddenAccelerometer:(BOOL)forbidden;

/// 设置微信OpenSDK的appId和universalLink
/// - Parameters:
///   - appId: 微信开放平台App ID
///   - universalLink: 微信开放平台Universal Link
/// - note: 若媒体已使用OpenSDK初始化，此方法无需调用
+ (void)setWXAppId:(NSString *)appId universalLink:(NSString *)universalLink;

#pragma mark: - Location

/// 禁止SDK获取位置信息，默认值为NO：即允许获取
+ (void)forbiddenLocation:(BOOL)forbidden;

/// 当用户禁止SDK获取位置信息时，可自行传入位置信息
/// @param latitude 实时的地理位置纬度
/// @param longitude 实时的地理位置经度
+ (void)setUserLocationLatitude:(NSString *)latitude longitude:(NSString *)longitude;

@end

NS_ASSUME_NONNULL_END
