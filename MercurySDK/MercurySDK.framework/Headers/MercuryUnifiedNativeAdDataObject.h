//
//  MercuryUnifiedNativeAdDataObject.h
//  MercurySDK
//
//  Created by guangyao on 2024/1/8.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryVideoConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryUnifiedNativeAdDataObject : NSObject
/// 广告标题
@property (nonatomic, copy, readonly) NSString *title;
/// 广告描述
@property (nonatomic, copy, readonly) NSString *desc;
/// 广告图标Url
@property (nonatomic, copy, readonly) NSString *iconUrl;
/// 广告大图Url
@property (nonatomic, copy, readonly) NSString *imageUrl;
/// 三小图广告的图片Url集合
@property (nonatomic, strong, readonly) NSArray *imageUrlList;
/// 素材宽度（单图、三图、视频）
@property (nonatomic, assign) NSInteger mediaWidth;
/// 素材高度（单图、三图、视频）
@property (nonatomic, assign) NSInteger mediaHeight;
/// 是否为三小图广告
@property (nonatomic, readonly) BOOL isThreeImgsAd;
/// 是否为视频广告
@property (nonatomic, readonly) BOOL isVideoAd;
/// 实时价格（分）
@property (nonatomic, readonly) NSInteger price;
/// 广告对应的按钮展示文案
@property (nonatomic, copy, readonly) NSString *buttonText;
/// 广告平台logo图
@property (nonatomic, copy, readonly) NSString *logoUrl;
/// 广告平台logo文字
@property (nonatomic, copy, readonly) NSString *logoText;
/// 视频广告播放配置
@property (nonatomic, strong) MercuryVideoConfig *videoConfig;

@end

NS_ASSUME_NONNULL_END
