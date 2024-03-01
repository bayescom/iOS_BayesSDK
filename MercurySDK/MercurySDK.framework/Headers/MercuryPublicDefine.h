//
//  MercuryPublicDefine.h
//  Mercury
//
//  Created by CherryKing on 2019/12/9.
//  Copyright © 2019 Mercury. All rights reserved.
//

#ifndef MercuryPublicDefine_h
#define MercuryPublicDefine_h

typedef NS_ENUM(NSUInteger, MercuryMediaPlayerStatus) {
    MercuryMediaPlayerStatusInitial = 0,    // 初始状态
    MercuryMediaPlayerStatusLoading = 1,    // 加载中
    MercuryMediaPlayerStatusPlaying = 2,    // 播放中
    MercuryMediaPlayerStatusPaused  = 3,    // 已暂停
    MercuryMediaPlayerStatusStoped  = 4,    // 已停止
    MercuryMediaPlayerStatusError   = 5,    // 播放出错
};

typedef NS_ENUM(NSInteger, MercuryVideoAutoPlayPolicy) {
    MercuryVideoAutoPlayPolicyWIFI   = 0, // WIFI 下自动播放(如果是已缓存过的文件 也会自动播放)
    MercuryVideoAutoPlayPolicyAlways = 1, // 总是自动播放，无论网络条件
    MercuryVideoAutoPlayPolicyNever  = 2, // 从不自动播放，无论网络条件
};

typedef NS_ENUM(NSInteger, MercuryMaterialType) { // 物料类型
    MercuryMaterialTypeUnKnow  = 0, // 未知, 还未获取素材时为该类型
    MercuryMaterialTypeImage   = 1, // 静态图片
    MercuryMaterialTypeGif     = 2, // Gif图片
    MercuryMaterialTypeVideo   = 3, // 视频
};

typedef NS_ENUM(NSInteger, MercuryTargetLinkType) { // 点击广告时 跳转link的类型
    MercuryTargetLinkTypeDeepLink  = 0, // deeplink
    MercuryTargetLinkTypeLDLink    = 1, // 普通落地页
    MercuryTargetLinkTypeOther     = 2, // 其他 (目前没用)
};

#endif
