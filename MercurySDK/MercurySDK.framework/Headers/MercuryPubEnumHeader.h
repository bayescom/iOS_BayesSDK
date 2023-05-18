//
//  MercuryPubEnumHeader.h
//  Example
//
//  Created by CherryKing on 2019/12/9.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#ifndef MercuryPubEnumHeader_h
#define MercuryPubEnumHeader_h

typedef NS_ENUM(NSUInteger, MercuryMediaPlayerStatus) {
    MercuryMediaPlayerStatusInitial = 0,    // 初始状态
    MercuryMediaPlayerStatusLoading = 1,    // 加载中
    MercuryMediaPlayerStatusPlaying = 2,    // 播放中
    MercuryMediaPlayerStatusPaused  = 3,    // 已暂停
    MercuryMediaPlayerStatusStoped  = 4,    // 已停止
    MercuryMediaPlayerStatusError   = 5,    // 播放出错
};

typedef NS_ENUM(NSInteger, MercuryMediaPlayererror) {
    MercuryMediaPlayererrorNoError          = 0, /// 正常播放
    MercuryMediaPlayererrorOtherSituations  = 1, /// 其他情况
    MercuryMediaPlayererrorVideoUrlError    = 100, /// 视频地址不正确
    MercuryMediaPlayererrorNetworkOvertime  = -1001, /// 请求超时：-1001
    MercuryMediaPlayererrorServerNotFound   = -1003, /// 找不到服务器：-1003
    MercuryMediaPlayererrorServerInternalError = -1004, /// 服务器内部错误：-1004
    MercuryMediaPlayererrorNetworkInterruption = -1005, /// 网络中断：-1005
    MercuryMediaPlayererrorNetworkNoConnection = -1009, /// 无网络连接：-1009
};

typedef NS_ENUM(NSUInteger, MercuryNativeExpressAdSizeMode) {
    /// 自动按照给出容器的宽度计算高度
    MercuryNativeExpressAdSizeModeAutoSize = 0,
    /// 超出父容器的部分会被截取，不足则会居中
    MercuryNativeExpressAdSizeModeMask,
};

typedef NS_ENUM(NSInteger, MercuryVideoAutoPlayPolicy) {
    MercuryVideoAutoPlayPolicyWIFI   = 0, // WIFI 下自动播放(如果是已缓存过的文件 也会自动播放)
    MercuryVideoAutoPlayPolicyAlways = 1, // 总是自动播放，无论网络条件
    MercuryVideoAutoPlayPolicyNever  = 2, // 从不自动播放，无论网络条件
};

typedef NS_ENUM(NSInteger, MercuryMaterialType) { // 物料类型
    MercuryMaterialTypeUnKnow  = 0, // 未知, 还未获取素材是为该类型
    MercuryMaterialTypeImage   = 1, // 图片
    MercuryMaterialTypeGif     = 2, // Gif
    MercuryMaterialTypeVideo   = 3, // video
};

typedef NS_ENUM(NSInteger, MercuryTargetLinkType) { // 点击广告时 跳转link的类型
    MercuryTargetLinkTypeDeepLink  = 0, // deeplink
    MercuryTargetLinkTypeLDLink    = 1, // 普通落地页
    MercuryTargetLinkTypeOther     = 2, // 其他 (目前没用)
};


// MARK: ======================= Enum Helper =======================
//static NSString * kMercuryMediaPlayerStatusParseToString(MercuryMediaPlayerStatus status) {
//    if (status == MercuryMediaPlayerStatusInitial) {
//        return @"MercuryMediaPlayerStatusInitial";
//    } else if (status == MercuryMediaPlayerStatusLoading) {
//        return @"MercuryMediaPlayerStatusLoading";
//    } else if (status == MercuryMediaPlayerStatusPlaying) {
//        return @"MercuryMediaPlayerStatusPlaying";
//    } else if (status == MercuryMediaPlayerStatusPaused) {
//        return @"MercuryMediaPlayerStatusPaused";
//    } else if (status == MercuryMediaPlayerStatusStoped) {
//        return @"MercuryMediaPlayerStatusStoped";
//    } else if (status == MercuryMediaPlayerStatusError) {
//        return @"MercuryMediaPlayerStatusError";
//    }
//    return @"status 不存在";
//}

#endif
