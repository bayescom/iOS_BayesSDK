//
//  MercuryServerBiddingProtocol.h
//  MercurySDK
//
//  Created by guangyao on 2026/8/18.
//  Copyright © 2026 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryAdMaterial.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryServerBiddingProtocol <NSObject>

@required

/// 获取 sdkInfo 用于 Server Bidding 请求获取 token
- (NSString *)getSDKInfo;

/// 请求bidding广告
/// - Parameter token: 媒体传入竞价成功的广告token
- (void)loadBiddingAd:(NSString *)token;

/// 获取广告素材
- (MercuryAdMaterial *)getAdMaterial;

@end

NS_ASSUME_NONNULL_END
