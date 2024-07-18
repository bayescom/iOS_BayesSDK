//
//  MercuryRewardedVideoModel.h
//  MercurySDK
//
//  Created by guangyao on 2024/7/8.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MercuryRewardedVideoModel : NSObject

//app user Identifier
@property (nonatomic, copy, nullable) NSString *userId;

//optional. serialized string.
@property (nonatomic, copy, nullable) NSString *extra;

//reward name.
@property (nonatomic, copy, nullable) NSString *rewardName;

//number of rewards
@property (nonatomic, assign) NSInteger rewardAmount;

@end

NS_ASSUME_NONNULL_END
