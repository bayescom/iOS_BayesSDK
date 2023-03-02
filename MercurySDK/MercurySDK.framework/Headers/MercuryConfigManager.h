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
//FOUNDATION_EXPORT NSString * const kMercuryConfigIdfaAuth;

// MARK: ======================= 配置信息Key =======================
// 1. 如果设置了kMercuryConfigCAID  这不需要再传 kMercuryConfigCAIDPublicKey, kMercuryConfigCAIDPublicForApiKey, kMercuryConfigCAIDDevId
// 2. 若没有设置kMercuryConfigCAID  则必须要传 kMercuryConfigCAIDPublicKey, kMercuryConfigCAIDPublicForApiKey, kMercuryConfigCAIDDevId 否则可能会影响收益
// 3. 同时设置, 则只有 kMercuryConfigCAID 生效
// 4. 以下四个字段类型必须为字符串类型
//FOUNDATION_EXPORT NSString * const kMercuryConfigCAID; // CAID 对应的key
//FOUNDATION_EXPORT NSString * const kMercuryConfigCAIDPublicKey; // CAID 用文本编辑打开pub_for_sdk.cer即可获取
//FOUNDATION_EXPORT NSString * const kMercuryConfigCAIDPublicForApiKey;// 用文本编辑打开public_for_api.pem即可获取
//FOUNDATION_EXPORT NSString * const kMercuryConfigCAIDDevId;// 申请获得

@interface MercuryConfigManager : NSObject


/// 设置AppID
/// @param appID 应用的AppID
/// @param appKey 媒体Key
+ (void)setAppID:(NSString *)appID appKey:(NSString *)appKey;

/// 设置AppID
/// @param appID 应用的AppID
/// @param appKey 媒体Key
/// @param config 配置信息 如果SDK集成者自己申请CAID 请将其放入config里面
+ (void)setAppID:(NSString *)appID appKey:(NSString *)appKey config:(NSDictionary *)config;

#pragma 下面两种设置方法 未来会被废弃
/// 设置AppID
/// @param appID 应用的AppID
/// @param mediaKey 媒体Key
+ (void)setAppID:(NSString *)appID mediaKey:(NSString *)mediaKey;

/// 设置AppID
/// @param appID 应用的AppID
/// @param mediaKey 媒体Key
/// @param config 配置信息 如果SDK集成者自己申请CAID 请将其放入config里面
+ (void)setAppID:(NSString *)appID mediaKey:(NSString *)mediaKey config:(NSDictionary *)config;



/// 选择是否开启日志打印
/// @param isDebug 是否打印日志
+ (void)openDebug:(BOOL)isDebug;

/// 获取 SDK 版本
+ (NSString *)sdkVersion;

/// 是否需要预缓存资源
+ (void)preloadedResourcesIfNeed:(BOOL)isNeed;

/// 设置ua
/// 联调时发现ua不符合规范 可用此方法传入ua 此处需传原始ua
/// 需在初始化时 调用该方法
+ (void)setDefaultUserAgent:(NSString *)ua;

/// 是否需要支持HTPPS  默认不需要
+ (void)supportHttps:(BOOL)isNeed;


/// 是否允许个性化广告推送 默认为允许
+ (void)openAdTrack:(BOOL)open;


@end

NS_ASSUME_NONNULL_END
