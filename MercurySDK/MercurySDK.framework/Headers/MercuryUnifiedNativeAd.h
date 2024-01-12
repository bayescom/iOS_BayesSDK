//
//  MercuryUnifiedNativeAd.h
//  MercurySDK
//
//  Created by guangyao on 2024/1/8.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryUnifiedNativeAdDataObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryUnifiedNativeAdDelegate <NSObject>

/**
 广告数据回调

 @param unifiedNativeAdDataObjects 广告数据数组
 @param error 错误信息
 */
- (void)mercury_unifiedNativeAdLoaded:(NSArray<MercuryUnifiedNativeAdDataObject *> * _Nullable)unifiedNativeAdDataObjects error:(NSError * _Nullable)error;

@end

@interface MercuryUnifiedNativeAd : NSObject

@property (nonatomic, weak) id<MercuryUnifiedNativeAdDelegate> delegate;

/// 构造方法
/// @param adspotId 广告Id
/// @param delegate 代理对象
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercuryUnifiedNativeAdDelegate> _Nullable)delegate;

/// 构造方法 (可携带自定义参数)
/// @param adspotId 广告id
/// @param ext 自定义参数
/// @param delegate 代理
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                         customExt:(NSDictionary * _Nullable)ext
                          delegate:(id<MercuryUnifiedNativeAdDelegate> _Nullable)delegate;

/**
 加载广告，仅加载一条数据
 */
- (void)loadAd;

/**
 加载广告
 @param adCount 加载条数
 */
- (void)loadAdWithAdCount:(NSInteger)adCount;

@end

NS_ASSUME_NONNULL_END
