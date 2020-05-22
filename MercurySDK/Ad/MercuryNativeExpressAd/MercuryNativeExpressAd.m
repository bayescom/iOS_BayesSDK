//
//  MercuryNativeExpressAd.m
//  Example
//
//  Created by CherryKing on 2019/12/13.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryNativeExpressAd.h"
#import "MercuryExceptionCollector.h"
#import "MercuryAdModel.h"
#import "MercuryPriHeader.h"
#import "MercuryDeviceInfoUtil.h"

@interface MercuryNativeExpressAd ()
@property (nonatomic, copy) NSString *adspotId;
@property (nonatomic, strong) MercuryAdModel *adModel;
@property (nonatomic, strong) NSMutableArray<MercuryNativeExpressAdView *> *arrM;
@end

@implementation MercuryNativeExpressAd

- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId {
    if (self = [self initAdWithAdspotId:adspotId delegate:nil]) {}
    return self;
}

- (instancetype)initAdWithAdspotId:(NSString *)adspotId delegate:(id<MercuryNativeExpressAdDelegete>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _adspotId = adspotId;
        _arrM = [NSMutableArray array];
    }
    return self;
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
            for (MercuryImp *imp in self.adModel.imp) {
                MercuryNativeExpressAdView *adView = [[MercuryNativeExpressAdView alloc] initAdWithImp:imp size:self.renderSize];
                adView.handle.muted = self.isVideoMuted;
                adView.handle.videoPlayPolicy = self.videoPlayPolicy;
                [self.arrM addObject:adView];
            }
            if ([self.delegate respondsToSelector:@selector(mercury_nativeExpressAdSuccessToLoad:views:)]) {
                [self.delegate mercury_nativeExpressAdSuccessToLoad:self views:[self.arrM copy]];
            }
        } else {
        }
    }];
}

@end
