//
//  MercuryDeviceInfoUtil.h
//  MercurySDK
//
//  Created by CherryKing on 2019/11/4.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MercuryDeviceInfoUtil : NSObject

/// 屏幕高度
@property (nonatomic, assign, readonly) CGFloat screenHeight;
/// 屏幕宽度
@property (nonatomic, assign, readonly) CGFloat screenWidth;
/// 屏幕Bounds
@property (nonatomic, assign, readonly) CGRect bounds;
/// User-Agent
@property (nonatomic, copy, readonly) NSString *ua;
/// AppId
@property (nonatomic, copy) NSString *appId;
/// MediaKey
@property (nonatomic, copy) NSString *mediaKey;

+ (NSString *)getIdfa;

/// 设备信息单例对象
+ (instancetype)sharedInstance;

/// 根据参数获取设备数据
/// 描述: 获取到设备信息后，回调 completion
/// @param adspotId adspotId
/// @param appId appId
/// @param mediaKey mediaKey
/// @param completion 获取到设备信息后的回调
- (void)getDeviceInfoWithAdspotId:(NSString*)adspotId
                            appId:(NSString*)appId
                         mediaKey:(NSString*)mediaKey
                       completion:(void (^ __nullable)(NSDictionary *deviceInfo))completion;

/// 清空设备缓存信息 (Cache & Disk)
- (void)clearDeviceInfoCache;


@end

NS_ASSUME_NONNULL_END
