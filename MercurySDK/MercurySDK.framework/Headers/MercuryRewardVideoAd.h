//
//  MercuryRewardVideoAd.h
//  MercurySDK
//
//  Created by guangyao on 2023/12/19.
//  Copyright © 2023 mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MercuryRewardVideoAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryRewardVideoAd : NSObject

@property (nonatomic, weak) id<MercuryRewardVideoAdDelegate> delegate;

/// 广告是否有效
@property (nonatomic, assign, readonly) BOOL isAdValid;

/// 实时价格（分）
@property (nonatomic, assign) NSInteger price;

/// 初始化激励广告
/// @param adspotId 广告Id
/// @param delegate 代理对象
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercuryRewardVideoAdDelegate> _Nullable)delegate;

/// 构造方法 (可携带自定义参数)
/// @param adspotId 广告id
/// @param ext 自定义参数
/// @param delegate 代理
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                         customExt:(NSDictionary * _Nullable)ext
                          delegate:(id<MercuryRewardVideoAdDelegate> _Nullable)delegate;

/// 加载广告
- (void)loadAd;

- (void)loadRewardVideoAd __attribute__((deprecated("接口即将废弃，请使用loadAd")));

/// 展示广告
- (void)showAdFromRootViewController:(UIViewController *)rootViewController;

- (void)showAdFromVC:(UIViewController *)vc __attribute__((deprecated("接口即将废弃，请使用showAdFromRootViewController:")));

@end

NS_ASSUME_NONNULL_END
