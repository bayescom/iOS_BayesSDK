//
//  MercuryNativeAd.m
//  Example
//
//  Created by CherryKing on 2019/11/20.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryNativeAd.h"
#import "MercuryAdModel.h"
#import "MercuryPriHeader.h"
#import "MercuryDeviceInfoUtil.h"

@interface MercuryNativeAd ()
@property (nonatomic, copy) NSString *adspotId;
@property (nonatomic, strong) MercuryAdModel *adModel;

@end

@implementation MercuryNativeAd

- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId {
    if (self = [self initAdWithAdspotId:adspotId delegate:nil]) {}
    return self;
}

- (instancetype)initAdWithAdspotId:(NSString *)adspotId delegate:(id<MercuryNativeAdDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _adspotId = adspotId;
    }
    return self;
}

- (void)loadAd {
    [self loadAdWithCount:1];
}

- (void)loadAdWithCount:(NSInteger)count {
    @mer_weakify(self);
    [MercuryAdModel loadAdWithAdspotId:_adspotId
                                 appId:MercuryDeviceInfoUtil.sharedInstance.appId
                              mediaKey:MercuryDeviceInfoUtil.sharedInstance.mediaKey
                               impsize:count
                            fetchDelay:3
                           resultBlock:^(NSError * _Nonnull error, MercuryAdModel * _Nonnull adModel) {
        @mer_strongify(self);
        if (!error) {
            self.adModel = adModel;
            if ([self.delegate respondsToSelector:@selector(mercury_nativeAdLoaded:error:)]) {
                [self.delegate mercury_nativeAdLoaded:adModel.imp error:error];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(mercury_nativeAdLoaded:error:)]) {
                [self.delegate mercury_nativeAdLoaded:@[] error:error];
            }
        }
    }];
}

@end
