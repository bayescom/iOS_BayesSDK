//
//  MercuryBaseAdObject.h
//  MercurySDK
//
//  Created by guangyao on 2024/5/30.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryAdEventModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryBaseAdObject : NSObject
/// 广告位id
@property (nonatomic, copy) NSString *adspotId;
/// 广告请求id
@property (nonatomic, copy) NSString *reqId;
/// 广告位初始化扩展参数
@property (nonatomic, strong) NSMutableDictionary *ext;
/// 埋点事件对象
@property (nonatomic, strong) MercuryAdEventModel *eventModel;

/// 埋点上报
- (void)uploadSDKEventWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
