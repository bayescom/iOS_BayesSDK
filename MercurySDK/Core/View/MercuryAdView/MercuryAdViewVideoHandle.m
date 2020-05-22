//
//  MercuryAdViewVideoHandle.m
//  MercurySDKExample
//
//  Created by CherryKing on 2020/5/9.
//  Copyright © 2020 mercury. All rights reserved.
//

#import "MercuryAdViewVideoHandle.h"
#import "MercuryAdView.h"

@interface MercuryAdViewVideoHandle ()
@property (nonatomic, weak) MercuryAdView *adView;

@end

@implementation MercuryAdViewVideoHandle

+ (instancetype)defaultHandle {
    MercuryAdViewVideoHandle *handle = [MercuryAdViewVideoHandle new];
    handle.muted = YES;
    handle.videoPlayPolicy = MercuryVideoAutoPlayPolicyWIFI;
    handle.showPlayProgress = NO;
    handle.stopAutoExpCheckFlag = NO;
    handle.hiddenSource = NO;
    handle.autoResumeEnable = NO;
    handle.removeWaterMarkFlag = NO;
    handle.userControlEnable = NO;
    return handle;
}

+ (instancetype)managerWithAdView:(MercuryAdView *)adView {
    return [[MercuryAdViewVideoHandle alloc] initWithAdView:adView];
}

- (instancetype)initWithAdView:(MercuryAdView *)adView {
    if (self = [super init]) {
        [self configAdView:adView];
    }
    return self;
}

- (void)configAdView:(MercuryAdView *)adView {
    self.adView = adView;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

// MARK: ======================= set =======================
@end
