//
//  MercuryNativeExpressAd.h
//  Example
//
//  Created by CherryKing on 2019/12/13.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryPubEnumHeader.h"
#import "MercuryNativeExpressAdView.h"

//@class MercuryNativeExpressAdView;
@class MercuryNativeExpressAd;

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryNativeExpressAdDelegete <NSObject>

@optional
/// 拉取原生模板广告成功 | (注意: nativeExpressAdView在此方法执行结束不被强引用，nativeExpressAd中的对象会被自动释放)
- (void)mercury_nativeExpressAdSuccessToLoad:(MercuryNativeExpressAd *)nativeExpressAd views:(NSArray<MercuryNativeExpressAdView *> *)views;

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoadWithError:(NSError *)error;

@end

@interface MercuryNativeExpressAd : NSObject

/// 广告展示的宽高
@property (nonatomic, assign) CGSize renderSize;

/// 代理
@property (nonatomic, weak) id<MercuryNativeExpressAdDelegete> delegate;

/// 播放策略
@property (nonatomic, assign) MercuryVideoAutoPlayPolicy videoPlayPolicy;

/// 自动播放时，是否静音。默认 YES。
@property (nonatomic, assign, getter=isVideoMuted) BOOL videoMuted;

/// 构造方法
/// @param adspotId adspotId
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId;

/// 加载广告
- (void)loadAdWithCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
