//
//  MercuryUnifiedNativeAdDataObject.h
//  MercurySDK
//
//  Created by guangyao on 2024/1/8.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@property (nonatomic, copy, readonly) NSArray *imageUrlList;
/// 是否为三小图广告
@property (nonatomic, readonly) BOOL isThreeImgsAd;
/// 是否为视频广告
@property (nonatomic, readonly) BOOL isVideoAd;
/// 实时价格（分）
@property (nonatomic, readonly) NSInteger price;
/// 广告对应的按钮展示文案
@property (nonatomic, readonly) NSString *buttonText;
/// 倍业广告logoUrl
@property (nonatomic, readonly) NSString *logoUrl;
/// 倍业广告logoText
@property (nonatomic, readonly) NSString *logoText;

@end

NS_ASSUME_NONNULL_END
