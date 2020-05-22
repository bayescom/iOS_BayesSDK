//
//  MercuryRewardVideoAd.m
//  Example
//
//  Created by CherryKing on 2019/11/26.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryRewardVideoAd.h"
#import "MercuryExceptionCollector.h"
#import "MercuryRewardVideoAdVC.h"
#import "MercuryPriHeader.h"
#import "MercuryDeviceInfoUtil.h"

@interface MercuryRewardVideoAd () <MercuryRewardVideoAdDelegate>
@property (nonatomic, strong) MercuryRewardVideoAdVC *adVc;
@property (nonatomic, copy) NSString *adspotId;

@end

@implementation MercuryRewardVideoAd

/// 初始化激励广告
/// @param adspotId 广告Id
/// @param delegate 代理对象
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercuryRewardVideoAdDelegate> _Nullable)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _adspotId = adspotId;
    }
    return self;
}

- (void)dealloc {
    self.adVc = nil;
    NSLog(@"%s", __func__);
}

/// 加载广告
- (void)loadRewardVideoAd {
    if (!_adVc) {
        @mer_weakify(self);
        _adVc = [[MercuryRewardVideoAdVC alloc] initAdWithAdspotId:_adspotId
                                                             appId:MercuryDeviceInfoUtil.sharedInstance.appId
                                                          mediaKey:MercuryDeviceInfoUtil.sharedInstance.mediaKey completion:^{
            @mer_strongify(self);
            self.adVc = nil;
        }];
        _adVc.modalPresentationStyle = 0;
        _adVc.delegate = _delegate;
    }
}

/// 弹出激励广告
- (void)showAdFromVC:(UIViewController *)vc {
    [_adVc showFromVC:vc];
}

@end
