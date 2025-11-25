//
//  MercuryAdMaterial.h
//  MercurySDK
//
//  Created by guangyao on 2024/2/21.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MercuryAdMaterial : NSObject
/// 请求id
@property (nonatomic, copy) NSString *reqId;
/// 广告素材的唯一标识id
@property (nonatomic, copy) NSString *materialId;
/// 广告主
@property (nonatomic, copy) NSString *advertiser;
/// 广告标题
@property (nonatomic, copy) NSString *title;
/// 广告描述
@property (nonatomic, copy) NSString *desc;
/// 广告图标Url
@property (nonatomic, copy) NSString *iconUrl;
/// 图片广告Url集合
@property (nonatomic, strong) NSArray<NSString *> *imageUrls;
/// 视频广告Url
@property (nonatomic, copy) NSString *videoUrl;
/// 广告对应的按钮展示文案
@property (nonatomic, copy) NSString *buttonText;

@end

NS_ASSUME_NONNULL_END
