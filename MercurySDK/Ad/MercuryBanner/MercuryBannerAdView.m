//
//  MercuryBannerAdView.m
//  Example
//
//  Created by CherryKing on 2019/11/8.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryBannerAdView.h"
#import "MercuryPriHeader.h"
#import "MercuryAdModel.h"
#import "UIImageView+WebCache.h"
#import "MercuryReachability.h"
#import "MercuryExceptionCollector.h"

#import "MercuryGCDTimer.h"
#import "UIView+Mercury.h"
#import "MercuryAdView.h"
#import "MercuryDeviceInfoUtil.h"

@interface MercuryBannerAdView () <MercuryAdViewDelegate>
@property (nonatomic, strong) MercuryAdView *adView;
@property (nonatomic, strong) MercuryAdModel *adModel;
@property (nonatomic, strong) MercuryImp *curImp;

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, copy) NSString *adspotId;
@property (nonatomic, strong) MercuryGCDTimer *timer;
@end

@implementation MercuryBannerAdView

- (instancetype)initWithAdspotId:(NSString *)adspotId {
    if (self = [self initWithFrame:CGRectZero adspotId:adspotId delegate:nil]) {
        
    }
    return self;
}

- (instancetype _Nullable )initWithFrame:(CGRect)frame
                                adspotId:(NSString *_Nullable)adspotId
                                delegate:(id<MercuryBannerAdViewDelegate> _Nullable)delegate {
    if (self = [super init]) {
        _showCloseBtn = YES;
        _fetchDelay = 3;
        _interval = 30;
        _delegate = delegate;
        _adspotId = adspotId;
        self.frame = frame;
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [_timer stopTimer];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [_adView destory];
    [_timer stopTimer];
}

- (void)loadAdAndShow {
    if (!_timer) {
        // 主动刷新计时
        _timer = [MercuryGCDTimer timerWithTimeInterval:self.interval runBlock:^{
            [self.adView removeFromSuperview];
            self.adView = nil;
            [self reloadData];
        }];
    }
}

// 真正开始请求数据
- (void)reloadData {
    if (!_adView) {
        @mer_weakify(self);
        [MercuryAdModel loadAdWithAdspotId:_adspotId
                                     appId:MercuryDeviceInfoUtil.sharedInstance.appId
                                  mediaKey:MercuryDeviceInfoUtil.sharedInstance.mediaKey
                                fetchDelay:_fetchDelay
                               resultBlock:^(NSError * _Nonnull error, MercuryAdModel * _Nonnull adModel) {
            @mer_strongify(self);
            if (!error) {
                if (![adModel.imp.firstObject checkAdType:MercuryAdModelType04
                                            creativeTypes:@[@(MercuryAdModelCreativeType03)]]) {
                    if ([self.delegate respondsToSelector:@selector(mercury_bannerViewFailToReceived:)]) {
                        [self.delegate mercury_bannerViewFailToReceived:[MercuryError errorWitherror:MercuryResultCode211].toNSError];
                    }
                    [self removeFromSuperview];
                    return;
                }
                self.adModel = adModel;
                self.curImp = self.adModel.imp.firstObject;
                if ([self.delegate respondsToSelector:@selector(mercury_bannerViewDidReceived)]) {
                    [self.delegate mercury_bannerViewDidReceived];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(mercury_bannerViewFailToReceived:)]) {
                    [self.delegate mercury_bannerViewFailToReceived:error];
                }
                [self removeFromSuperview];
            }
        }];
    }
}

// MARK: ======================= Action =======================
- (void)dismissSelf:(UIButton *)sender {
    [self removeFromSuperview];
    [_timer stopTimer];
    if ([_delegate respondsToSelector:@selector(mercury_bannerViewWillClose)]) {
        [_delegate mercury_bannerViewWillClose];
    }
}

// MARK: ======================= MercuryAdViewDelegate =======================
/// 广告内容被点击
- (void)mercuryAdViewDidClickWithImp:(MercuryImp *)imp {
    if ([self.delegate respondsToSelector:@selector(mercury_bannerViewClicked)]) {
        [self.delegate mercury_bannerViewClicked];
    }
}

/// 广告内容被曝光
- (void)mercuryAdViewDidExpressWithImp:(MercuryImp *)imp {
    if ([_delegate respondsToSelector:@selector(mercury_bannerViewWillExposure)]) {
        [_delegate mercury_bannerViewWillExposure];
    }
}

- (void)mercuryAdViewAdSourceDidRecevedWithImp:(MercuryImp *)imp size:(CGSize)impSize {
    [_adView addSubview:self.closeBtn];
    [_closeBtn.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_closeBtn.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [_closeBtn.widthAnchor constraintEqualToConstant:20].active = YES;
    [_closeBtn.heightAnchor constraintEqualToConstant:20].active = YES;
    
    if (_animationOn) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.6f];
        [UIView setAnimationTransition:(arc4random() % 4)+1 forView:self cache:NO];
        [UIView commitAnimations];
    }
}

// MARK: ======================= set =======================
- (void)setShowCloseBtn:(BOOL)showCloseBtn {
    _showCloseBtn = showCloseBtn;
    _closeBtn.hidden = !_showCloseBtn;
}

- (void)setCurImp:(MercuryImp *)curImp {
    _curImp = curImp;
    
    if (!_adView.superview) {
        _adView = [[MercuryAdView alloc] initAdWithImp:_curImp];
        
        _adView.delegate = self;
        [self addSubview:_adView];
        [_adView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [_adView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [_adView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [_adView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    }
    [_adView renderWithSize:self.bounds.size];
}

- (void)setInterval:(int)interval {
    if (interval < 30) {
        interval = 30;
    } else if (interval > 120) {
        interval = 120;
    }
    _interval = interval;
}

// MARK: ======================= get =======================
- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_closeBtn setImage:kMercuryImageNamed(@"_mercury_sdk3_0_close") forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
