//
//  MercuryAdEventModel.h
//  MercurySDK
//
//  Created by guangyao on 2024/5/29.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

@interface MercuryAdMaterialObject : NSObject
/// 1 - 图片，2 - 视频
@property (nonatomic, assign) NSInteger type;
/// 素材url链接
@property (nonatomic, copy) NSString *url;

@end

@interface MercuryAdEventModel : NSObject
/// 用户当前网络状态
@property (nonatomic, assign) NSInteger network;
/// 用户定位状态
@property (nonatomic, assign) NSInteger location_status;
/// SDK初始化时间戳，单位ms
@property (nonatomic, assign) NSInteger sdk_init_time;
/// 广告位初始化时间戳，单位ms
@property (nonatomic, assign) NSInteger init_time;
/// 是否serverbidding，1代表是
@property (nonatomic, assign) NSInteger is_serverbidding;
/// 广告获取是否成功，1代表成功
@property (nonatomic, assign) NSInteger ad_success;
/// 广告曝光是否成功，1代表成功
@property (nonatomic, assign) NSInteger expose_success;
/// 广告失败错误码
@property (nonatomic, assign) NSInteger err_code;
/// 广告失败错误信息
@property (nonatomic, copy) NSString *err_msg;
/// 广告位调用load方法的时间戳，单位ms
@property (nonatomic, assign) NSInteger load_time;
/// 请求准备耗时，单位ms，广告位初始化到发起请求的时间间隔。
@property (nonatomic, assign) NSInteger prepare_cost;
/// 广告请求耗时，单位ms，广告位初始化到广告返回结果（成功或失败）的时间间隔。
@property (nonatomic, assign) NSInteger ad_req_cost;
/// 广告位调用show方法的时间戳，单位ms
@property (nonatomic, assign) NSInteger show_time;
/// 广告曝光耗时，单位ms，广告调用show到广告曝光的时间间隔。
@property (nonatomic, assign) NSInteger expose_cost;
/// 广告素材对象
@property (nonatomic, strong) MercuryAdMaterialObject *ad_material;

@end

NS_ASSUME_NONNULL_END
