//
//  MercuryVideoConfig.h
//  MercurySDK
//
//  Created by guangyao on 2024/1/9.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MercuryVideoConfig : NSObject

/// 是否静音播放视频广告，默认 YES
@property (nonatomic, assign) BOOL videoMuted;

/** 能否接收点击事件，默认YES
 MediaView的事件响应由该属性控制，不需要执行-[MercuryUnifiedNativeAdView register:]操作
 */
@property (nonatomic, assign) BOOL canReceiveClickEvent;

@end

NS_ASSUME_NONNULL_END
