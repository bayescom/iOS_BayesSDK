//
//  MercuryRewardVideoAd.h
//  Example
//
//  Created by CherryKing on 2019/11/26.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MercuryRewardVideoAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryRewardVideoAd : NSObject
@property (nonatomic, weak) id<MercuryRewardVideoAdDelegate> delegate;

/// 插屏广告是否加载完成
@property (nonatomic, assign, readonly) BOOL isAdValid;

/// 素材超时时间
@property (nonatomic, assign) NSTimeInterval timeoutTime;

/// 实时价格
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
                         customExt:(NSDictionary * _Nonnull)ext
                          delegate:(id<MercuryRewardVideoAdDelegate> _Nullable)delegate;

/// 加载广告
- (void)loadRewardVideoAd;

/// 弹出激励广告
- (void)showAdFromVC:(UIViewController *)vc;
@end

NS_ASSUME_NONNULL_END
