//
//  MercuryPriEnumHeader.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/23.
//  Copyright © 2020 mercury. All rights reserved.
//

#ifndef MercuryPriEnumHeader_h
#define MercuryPriEnumHeader_h

/// 事件上报枚举
typedef NS_ENUM(NSUInteger, MercuryBaseAdRepoTKEventType) {
    /// 未知类型
    MercuryBaseAdRepoTKEventTypeUnknow       = 0,
    /// 曝光上报
    MercuryBaseAdRepoTKEventTypeShow         = 1,
    /// 广告点击上报
    MercuryBaseAdRepoTKEventTypeClick        = 2,
    /// 视频开始播放
    MercuryBaseAdRepoTKEventTypeVideoStart   = 3,
    /// 视频播放一半
    MercuryBaseAdRepoTKEventTypeVideoMid     = 4,
    /// 视频播放结束
    MercuryBaseAdRepoTKEventTypeVideoEnd     = 5,
    /// 视频播放到1/4
    MercuryBaseAdRepoTKEventTypeVideo1_4     = 6,
    /// 视频播放到3/4
    MercuryBaseAdRepoTKEventTypeVideo3_4     = 7,
    /// deeplink成功调起上报
    MercuryBaseAdRepoTKEventTypeDeeplink     = 10,
    /// 开屏倒计时结束上报
    MercuryBaseAdRepoTKEventTypeTend         = 11,
    /// 开屏点击跳过上报
    MercuryBaseAdRepoTKEventTypeSkip         = 12,
    /// link成功调起上报
    MercuryBaseAdRepoTKEventTypeLink         = 13,
};

typedef NS_ENUM(NSUInteger, MercuryAdModelType) { // 广告类型
    /// 开屏
    MercuryAdModelType01 = 1,
    /// 信息流
    MercuryAdModelType02 = 2,
    /// 视频贴片
    MercuryAdModelType03 = 3,
    /// 横幅
    MercuryAdModelType04 = 4,
    /// 插屏
    MercuryAdModelType05 = 5,
    /// 激励视频
    MercuryAdModelType06 = 6,
};

typedef NS_ENUM(NSUInteger, MercuryAdModelCreativeType) {    // (创意)广告类型
    /// 开屏 | 图片
    MercuryAdModelCreativeType01 = 1,
    /// 开屏 | 视频
    MercuryAdModelCreativeType02 = 2,
    /// 横幅 | 图片
    MercuryAdModelCreativeType03 = 3,
    /// 插屏 | 图片
    MercuryAdModelCreativeType04 = 4,
    /// 视频贴片 | 视频
    MercuryAdModelCreativeType05 = 5,
    /// 视频贴片 | 图片
    MercuryAdModelCreativeType06 = 6,
    /// 信息流 | 一图
    MercuryAdModelCreativeType07 = 7,
    /// 信息流 | 三图
    MercuryAdModelCreativeType08 = 8,
    /// 信息流 | 一视频
    MercuryAdModelCreativeType09 = 9,
    /// 激励视频 | 视频
    MercuryAdModelCreativeType10 = 10,
    /// 信息流 | 一图 一图标
    MercuryAdModelCreativeType21 = 21,
    /// 信息流 | 三图 一图标
    MercuryAdModelCreativeType22 = 22,
    /// 信息流 | 视频 一图标
    MercuryAdModelCreativeType23 = 23,
};

typedef NS_ENUM(NSUInteger, MercuryNativeExpressAdViewType) {
    /// 上图下文
    MercuryNativeExpressAdViewType00 = 0,
    /// 上文下图
    MercuryNativeExpressAdViewType01,
    /// 左图右文
    MercuryNativeExpressAdViewType02,
    /// 左文右图
    MercuryNativeExpressAdViewType03,
    /// 双图单文
    MercuryNativeExpressAdViewType04,
};

#endif
