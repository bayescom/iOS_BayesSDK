//
//  MercuryApiUtils.h
//  AAA
//
//  Created by CherryKing on 2019/10/30.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MercuryPriHeader.h"
#import "MercuryAdModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryApiUtils : NSObject

/// 单例
+ (instancetype)sharedInstance;

/// 发起广告请求
/// @param adspotId adspotId
/// @param appId appId
/// @param mediaKey mediaKey
/// @param resultBlock 结果回调
- (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
               resultBlock:(void (^ _Nullable)(NSError *error, MercuryAdModel *adModel))resultBlock;

/// 发起广告请求
/// @param adspotId adspotId
/// @param appId appId
/// @param mediaKey mediaKey
/// @param fetchDelay 设定超时时间
/// @param resultBlock 结果回调
- (void)loadAdWithAdspotId:(NSString *)adspotId
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
- (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
                   impsize:(NSInteger)impsize
                fetchDelay:(NSTimeInterval)fetchDelay
               resultBlock:(void (^ _Nullable)(NSError *error, MercuryAdModel *adModel))resultBlock;

/// ============================================= 数据上报 ===============================================

/// 按照事件上报数据(无点击上报)
/// @param adImp 需要被上报的广告
/// @param eventType 事件类型
/// @param resultBlock 上报结果回调
- (void)reportAdImp:(MercuryImp *)adImp
            adModel:(MercuryAdModel *)adModel
          eventType:(MercuryBaseAdRepoTKEventType)eventType
        resultBlock:(void (^ _Nullable)(BOOL isSuccess, MercuryBaseAdRepoTKEventType eventType))resultBlock;

/// 按照事件上报数据
/// @param adImp 需要被上报的广告
/// @param eventType 事件类型
/// @param beginPoint 手指按下位置
/// @param endPoint 手指抬起位置
/// @param resultBlock 上报结果回调
- (void)reportAdImp:(MercuryImp *)adImp
            adModel:(MercuryAdModel *)adModel
          eventType:(MercuryBaseAdRepoTKEventType)eventType
         beginPoint:(CGPoint)beginPoint
           endPoint:(CGPoint)endPoint
        resultBlock:(void (^ _Nullable)(BOOL isSuccess, MercuryBaseAdRepoTKEventType eventType))resultBlock;

/// 异常上报
- (void)reportErrorWithParams:(NSDictionary *)params
                  resultBlock:(void (^ _Nullable)(BOOL isSuccess))resultBlock;

/// 预缓存素材资源
- (void)preloadedResourcesIfNeed;

@end

NS_ASSUME_NONNULL_END
