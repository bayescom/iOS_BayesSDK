//
//  MercuryInterstitialAd.m
//  Example
//
//  Created by CherryKing on 2019/11/26.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryInterstitialAd.h"
#import "MercuryInterstitialAdVC.h"
#import "UIWindow+Mercury.h"
#import "MercuryPriHeader.h"
#import "MercuryGCDTimer.h"
#import "MercuryDeviceInfoUtil.h"

@interface MercuryInterstitialAd () <MercuryInterstitialAdDelegate>
@property (nonatomic, strong) MercuryInterstitialAdVC *adVc;
@property (nonatomic, copy) NSString *adspotId;

@end

@implementation MercuryInterstitialAd

- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId {
    if (self = [self initAdWithAdspotId:adspotId delegate:nil]) {}
    return self;
}

- (instancetype)initAdWithAdspotId:(NSString *)adspotId delegate:(id<MercuryInterstitialAdDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _adVc.delegate = _delegate;
        _adspotId = adspotId;
    }
    return self;
}

- (void)loadAd {
    if (!_adVc) {
        _adVc = [[MercuryInterstitialAdVC alloc] initAdWithAdspotId:_adspotId
                                                              appId:MercuryDeviceInfoUtil.sharedInstance.appId
                                                           mediaKey:MercuryDeviceInfoUtil.sharedInstance.mediaKey];
        _adVc.modalPresentationStyle = 0;
        _adVc.delegate = _delegate;
    }
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)presentAdFromViewController:(UIViewController *)fromViewController {
    if (_adVc) {
        _adVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        _adVc.providesPresentationContextTransitionStyle = YES;
        _adVc.definesPresentationContext = YES;
        _adVc.controller = fromViewController;
        [_adVc showFromVC:fromViewController];
    } else {
        NSLog(@"请重新请求");
    }
}

@end
