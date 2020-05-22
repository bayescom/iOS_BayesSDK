//
//  MercuryAdModel.h
//  AAA
//
//  Created by CherryKing on 2019/10/30.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryError.h"
#import "MercuryPriEnumHeader.h"
#import <UIKit/UIKit.h>

@class MercuryAdModel;
@class MercuryImp;
@class MercuryAppleAppInfoModel;

NS_ASSUME_NONNULL_BEGIN

/// 以字符串形式返回上报类型
FOUNDATION_EXPORT NSString * MercuryStringFromNMercuryBaseAdRepoTKEventType(MercuryBaseAdRepoTKEventType type);

#pragma mark - Object interfaces

@interface MercuryAdModel : NSObject
@property (nonatomic, assign) MercuryResultCode code;
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, assign) NSInteger tcost;
@property (nonatomic, copy)   NSArray<MercuryImp *> *imp;

/// 此广告发起请求的时间
@property (nonatomic, assign) NSTimeInterval adResponseTimeStamp;
/// 请求Id
@property (nonatomic, copy) NSString *reqId;
/// 广告Id
@property (nonatomic, copy) NSString *adspotId;
/// mediaId
@property (nonatomic, copy) NSString *mediaId;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;

///// 转换到信息流模型
//- (NSArray <MercuryNativeAdDataModel *> *)toNativeAdDataModel;

@end

@interface MercuryImp : NSObject
@property (nonatomic, copy)   NSString *impid;
@property (nonatomic, assign) NSInteger action;
@property (nonatomic, assign) NSInteger winPrice;
@property (nonatomic, copy)   NSString *link;
@property (nonatomic, copy)   NSString *deeplink;
@property (nonatomic, assign) MercuryAdModelType adtype;
@property (nonatomic, copy)   NSString *adsource;
@property (nonatomic, copy)   NSString *logo;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSArray<NSString *> *image;
@property (nonatomic, copy)   NSString *desc;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, copy)   NSString *vurl;
@property (nonatomic, copy)   NSString *video_image;
@property (nonatomic, assign) MercuryAdModelCreativeType creative_type;
@property (nonatomic, copy)   NSString *appleId;
@property (nonatomic, assign) MercuryNativeExpressAdViewType template_id;

/// 判断广告是否是视频广告
- (BOOL)isVideoType;
/// 判断广告类型是否匹配 YES 表示类型正确 NO表示类型错误
- (BOOL)checkAdType:(MercuryAdModelType)adType creativeTypes:(NSArray<NSNumber *> *)creativeTypes;

// 广告曝光的尺寸
/// 宽
@property (nonatomic, assign) float sizeW;
/// 高
@property (nonatomic, assign) float sizeH;

// MARK: ======================= 上报是否已经触发过 =======================
/// 是否触发过已点击上报
@property (nonatomic, assign) BOOL isClickedRepo;
/// 是否触发过曝光上报
@property (nonatomic, assign) BOOL isExposuredRepo;
/// 是否触发过Deeplink上报
@property (nonatomic, assign) BOOL isDpLinkRepo;
/// 是否触发过Link上报
@property (nonatomic, assign) BOOL isLinkRepo;
/// 是否触发过开屏倒计时结束上报
@property (nonatomic, assign) BOOL isTendRepo;
/// 是否触发过开屏点击跳过上报
@property (nonatomic, assign) BOOL isSkipRepo;

@property (nonatomic, assign) BOOL isVStartRepo;
@property (nonatomic, assign) BOOL isVMidRepo;
@property (nonatomic, assign) BOOL isVEndRepo;
@property (nonatomic, assign) BOOL isVFirstRepo;
@property (nonatomic, assign) BOOL isVThirdRepo;
@property (nonatomic, assign) BOOL isVCloseRepo;

// MARK: ======================= 事件上报 =======================
/// 曝光上报地址
@property (nonatomic, copy)   NSArray<NSString *> *imptk;
/// Deeplink点击上报
@property (nonatomic, copy)   NSArray<NSString *> *deeplinktk;
/// link点击上报
@property (nonatomic, copy)   NSArray<NSString *> *linktk;
/// 点击上报
@property (nonatomic, copy)   NSArray<NSString *> *clicktk;
/// 开屏倒计时结束上报
@property (nonatomic, copy)   NSArray<NSString *> *tendtk;
/// 开屏点击跳过上报
@property (nonatomic, copy)   NSArray<NSString *> *skiptk;

// MARK: ======================= Video 事件上报 =======================
@property (nonatomic, copy)   NSArray<NSString *> *starttk;
@property (nonatomic, copy)   NSArray<NSString *> *midtk;
@property (nonatomic, copy)   NSArray<NSString *> *endtk;
@property (nonatomic, copy)   NSArray<NSString *> *firsttk;
@property (nonatomic, copy)   NSArray<NSString *> *thirdtk;
@property (nonatomic, copy)   NSArray<NSString *> *closetk;

// MARK: ======================= Android Support =======================
//@property (nonatomic, copy)   NSArray<NSString *> *installedtk;
//@property (nonatomic, copy)   NSArray<NSString *> *installtk;
//@property (nonatomic, copy)   NSArray<NSString *> *downloadtk;
//@property (nonatomic, copy)   NSArray<NSString *> *downloadedtk;

/// 通过AppleId加载App信息(如不存在appleid，则直接返回nil)
//- (void)loadAppInfoModelIfHasCompletionHandler:(void (^)(MercuryAppleAppInfoModel * _Nullable appInfoModel, NSError * _Nullable error))completionHandler;

//- (MercuryNativeAdDataModel *)toNativeAdDataModel;

@end


@interface MercuryAdModel (API)

/// 发起广告请求
/// @param adspotId adspotId
/// @param appId appId
/// @param mediaKey mediaKey
/// @param resultBlock 结果回调
+ (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
               resultBlock:(void (^ _Nullable)(NSError *error, MercuryAdModel *adModel))resultBlock;

/// 发起广告请求
/// @param adspotId adspotId
/// @param appId appId
/// @param mediaKey mediaKey
/// @param fetchDelay 设定超时时间
/// @param resultBlock 结果回调
+ (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
                fetchDelay:(NSTimeInterval)fetchDelay
               resultBlock:(void (^ _Nullable)(NSError *error, MercuryAdModel *adModel))resultBlock;

/// 发起广告请求
/// @param adspotId adspotId
/// @param appId appId
/// @param mediaKey mediaKey
/// @param impsize 广告数量 默认1
/// @param fetchDelay 设定超时时间
/// @param resultBlock 结果回调
+ (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
                   impsize:(NSInteger)impsize
                fetchDelay:(NSTimeInterval)fetchDelay
               resultBlock:(void (^ _Nullable)(NSError *error, MercuryAdModel *adModel))resultBlock;

@end


@interface MercuryImp (Repo)
/// 按照事件上报数据(无点击上报)
/// @param eventType 事件类型
/// @param resultBlock 上报结果回调
- (void)reportWithEventType:(MercuryBaseAdRepoTKEventType)eventType
                resultBlock:(void (^ _Nullable)(BOOL isSuccess, MercuryBaseAdRepoTKEventType eventType))resultBlock;

/// 点击事件上报数据
/// @param beginPoint 手指按下位置
/// @param endPoint 手指抬起位置
/// @param resultBlock 上报结果回调
- (void)reportWithBeginPoint:(CGPoint)beginPoint
                    endPoint:(CGPoint)endPoint
                 resultBlock:(void (^ _Nullable)(BOOL isSuccess, MercuryBaseAdRepoTKEventType eventType))resultBlock;

/// 异常上报
- (void)reportErrorWithParams:(NSDictionary *)params
                  resultBlock:(void (^ _Nullable)(BOOL isSuccess))resultBlock;
@end

NS_ASSUME_NONNULL_END
