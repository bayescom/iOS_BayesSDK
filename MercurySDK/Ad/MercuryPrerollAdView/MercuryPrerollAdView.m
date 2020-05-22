//
//  MercuryPrerollAdView.m
//  Example
//
//  Created by CherryKing on 2019/12/16.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryPrerollAdView.h"
#import "MercuryPriHeader.h"
#import "MercuryAdView.h"
#import "MercuryAdModel.h"
#import "MercuryGCDTimer.h"
#import "MercuryDeviceInfoUtil.h"

@interface MercuryPrerollAdView () <MercuryAdViewDelegate>
@property (nonatomic, strong) MercuryAdView *adView;
@property (nonatomic, strong) MercuryAdModel *adModel;

@property (nonatomic, copy) NSString *adspotId;

@property (nonatomic, strong) UIView *skipV;
@property (nonatomic, assign) NSInteger skipTime;
@property (nonatomic, strong) UITapGestureRecognizer *skipGesRec;
@property (nonatomic, strong) NSLayoutConstraint *adViewAnchorH;
@property (nonatomic, strong) UILabel *skip02Lbl;   // 时间变动的Label

@property (nonatomic, strong) MercuryGCDTimer *timer;
@property (nonatomic, assign) NSInteger impIdx;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL isInit;

@end

@implementation MercuryPrerollAdView

- (instancetype)initWithAdspotId:(NSString *)adspotId {
    if (self = [self initWithFrame:CGRectZero adspotId:adspotId delegate:nil]) {
        
    }
    return self;
}

- (instancetype _Nullable )initWithFrame:(CGRect)frame
                                adspotId:(NSString *_Nullable)adspotId
                                delegate:(id<MercuryPrerollAdDelegate> _Nullable)delegate {
    if (self = [super init]) {
        _skipTime = 5; // 默认SkipTime = 5
        _delegate = delegate;
        _adspotId = adspotId;
        self.frame = frame;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.adView destory];
    self.adView = nil;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (!self.superview) { return; }
//    [self applicationLifeCycleNotification];
    self.frame = self.superview.bounds;
    if (_adView) {
        if (!CGSizeEqualToSize(self.superview.bounds.size, CGSizeZero)) {
            [_adView renderWithSize:self.superview.bounds.size];
        }
    } else {
        [self removeFromSuperview];
        NSLog(@"广告未准备完成");
    }
}

- (void)loadAd {
    @mer_weakify(self);
    [MercuryAdModel loadAdWithAdspotId:_adspotId
                                 appId:MercuryDeviceInfoUtil.sharedInstance.appId
                              mediaKey:MercuryDeviceInfoUtil.sharedInstance.mediaKey
                            fetchDelay:3
                           resultBlock:^(NSError * _Nonnull error, MercuryAdModel * _Nonnull adModel) {
        @mer_strongify(self);
        if (!error) {
            self.adModel = adModel;
//            self.curImp = self.adModel.imp.firstObject;
            if ([self.delegate respondsToSelector:@selector(mercury_prerollAdDidReceived)]) {
                [self.delegate mercury_prerollAdDidReceived];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(mercury_prerollAdFailToReceived:)]) {
                [self.delegate mercury_prerollAdFailToReceived:error];
            }
            [self removeFromSuperview];
        }
    }];
}

- (void)showAdWithView:(UIView *)view {
    if (!_adView.curImp.isExposuredRepo) {
        self.frame = self.superview.bounds;
        [view addSubview:self];
    } else {
        NSLog(@"此广告已曝光，请加载新广告");
    }
}

- (void)layoutSubviewsWithImpSize:(CGSize)impSize {
    if (!_adView || CGSizeEqualToSize(CGSizeZero, impSize)) {
        if ([self.delegate respondsToSelector:@selector(mercury_prerollAdFailError:)]) {
            [self.delegate mercury_prerollAdFailError:[MercuryError errorWitherror:MercuryResultCode300].toNSError];
        }
        [self.adView destory];
        self.adView = nil;
        return;
    }
    
    CGFloat real_w = self.bounds.size.width;//[UIScreen mainScreen].bounds.size.width;
    CGFloat real_h = self.bounds.size.height;//impSize.height*(real_w/impSize.width);
    
    // 广告内容
    [self addSubview:_adView];
    [_adView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_adView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [_adView.widthAnchor constraintEqualToConstant:real_w].active = YES;
    [_adView.heightAnchor constraintEqualToConstant:real_h].active = YES;
    
    [self addSubview:self.skipV];
    // 跳过按钮
    if (_skipV) {
        [_skipV.topAnchor constraintEqualToAnchor:_adView.topAnchor constant:8].active = YES;
        [_skipV.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-8].active = YES;
        [_skipV.heightAnchor constraintEqualToConstant:24.0].active = YES;
        [_skipV.widthAnchor constraintEqualToConstant:64.0].active = YES;

        _skipV.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:0.8];
    }

    [self sendSubviewToBack:self.adView];
}

// 跳过按钮
- (void)skpiBtnActionSelf:(UITapGestureRecognizer *)gesture {
    // 是否是最后一个广告
    if (self.adModel.imp.lastObject == self.adView.curImp) {
        [_timer stopTimer];
        [_adView destory];
        [self removeFromSuperview];
        if ([_delegate respondsToSelector:@selector(mercury_prerollAdClosed:)]) {
            [_delegate mercury_prerollAdClosed:self];
        }
        [_adView removeFromSuperview];
        _adView = nil;
    } else {
        // 加载下一个广告
        [self.adView loadAdWithImp:self.adModel.imp[++self.impIdx]];
        if (self.adModel.imp[self.impIdx].isVideoType) {
            _skipTime = MIN(_adView.totalTime, _adView.curImp.duration);
        } else {
            _skipTime = _adView.curImp.duration>0?_adView.curImp.duration:5;
        }
        self.skip02Lbl.text = [NSString stringWithFormat:@"%02ld", (long)self.skipTime--];
    }
}

// MARK: ======================= Notification =======================
//// 进入后台的通知
//- (void)applicationLifeCycleNotification {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
//}
//
//- (void)applicationDidBecomeActive {
//    // 开始自动播放检测
//    self.adView.stopAutoExpCheckFlag = NO;
////    [_timer resumeTimer];
//}
//
//- (void)applicationDidEnterBackground {
//    // 暂停且关闭自动播放检测
//    self.adView.stopAutoExpCheckFlag = YES;
//    [self.adView pause];
//
//}

// MARK: ======================= MercuryAdViewDelegate =======================
/// 广告内容被点击
- (void)mercuryAdViewDidClickWithImp:(MercuryImp *)imp {
    [_timer pauseTimer];
    if ([self.delegate respondsToSelector:@selector(mercury_prerollAdClicked:)]) {
        [self.delegate mercury_prerollAdClicked:self];
    }
}

/// 广告内容被曝光
- (void)mercuryAdViewDidExpressWithImp:(MercuryImp *)imp {
    if ([_delegate respondsToSelector:@selector(mercury_prerollAdExposured:)]) {
        [_delegate mercury_prerollAdExposured:self];
    }
    if (!imp.isVideoType) { // 图片广告使用默认倒计时
        [self beginTimer];
    } else {
        [_timer stopTimer];
        _timer = nil;
    }
}

- (void)beginTimer {
    [_timer stopTimer];
    _timer = nil;
    
    if (self.adView.curImp.isVideoType) {
        self.skipTime = MIN(self.adView.totalTime, self.adView.curImp.duration);
    } else {
        self.skipTime = self.adView.curImp.duration>0?self.adView.curImp.duration:5;
    }
    
    @mer_weakify(self);
    _timer = [MercuryGCDTimer timerWithTimeInterval:1 runBlock:^{
        @mer_strongify(self);
        if (self.skipTime <= 0) {
            if ([self.delegate respondsToSelector:@selector(mercury_prerollAdLifeTime:)]) {
                [self.delegate mercury_prerollAdLifeTime:self.skipTime];
            }
            // 到最后一个直接结束
            if (self.impIdx >= self.adModel.imp.count-1) {
                [self removeFromSuperview];
                [self.timer stopTimer];
                [self.adView destory];
            } else { // 加载下一个广告
                [self.adView loadAdWithImp:self.adModel.imp[++self.impIdx]];
                [self beginTimer];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(mercury_prerollAdLifeTime:)]) {
                [self.delegate mercury_prerollAdLifeTime:self.skipTime];
            }
            self.skip02Lbl.text = [NSString stringWithFormat:@"%02ld", (long)self.skipTime--];
        }
    }];
}

/// 广告资源尺寸被获取成功
- (void)mercuryAdViewAdSourceDidRecevedWithImp:(MercuryImp *)imp size:(CGSize)impSize {
    if (imp.isVideoType) {
        _skipTime = MIN(_adView.totalTime, _adView.curImp.duration);
    } else {
        _skipTime = _adView.curImp.duration>0?_adView.curImp.duration:5;
        // 图片广告在这一步先渲染子控件
    }
    [self layoutSubviewsWithImpSize:impSize];
}

- (void)mercuryAdViewVideoTimeCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime {
    if (ceil(currentTime) == 1) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideoStart resultBlock:nil];
    }
    if (ceil(currentTime) == ceil(totalTime*0.25)) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideo1_4 resultBlock:nil];
    }
    if (ceil(currentTime) == ceil(totalTime*0.5)) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideoMid resultBlock:nil];
    }
    if (ceil(currentTime) == ceil(totalTime*0.75)) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideo3_4 resultBlock:nil];
    }
    if (ceil(currentTime) >= ceil(totalTime)) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideoEnd resultBlock:nil];
    }
    
    if (currentTime >= totalTime) {
        if ([self.delegate respondsToSelector:@selector(mercury_prerollAdLifeTime:)]) {
            [self.delegate mercury_prerollAdLifeTime:@(totalTime-currentTime).unsignedIntegerValue];
        }
        // 到最后一个直接结束
        if (self.impIdx >= self.adModel.imp.count-1) {
            [self removeFromSuperview];
            [self.timer stopTimer];
            [self.adView destory];
        } else {
            // 加载下一个广告
            [self.adView loadAdWithImp:self.adModel.imp[++self.impIdx]];
            [self beginTimer];
        }
    } else {
        if (_skipTime != @(totalTime-currentTime).unsignedIntegerValue) {
            _skipTime = @(totalTime-currentTime).unsignedIntegerValue;
            if ([self.delegate respondsToSelector:@selector(mercury_prerollAdLifeTime:)]) {
                [self.delegate mercury_prerollAdLifeTime:_skipTime];
            }
            self.skip02Lbl.text = [NSString stringWithFormat:@"%02ld", @(totalTime-currentTime).longValue];
        }
    }
}

- (void)mercuryAdViewVideoStatusChangeWithImp:(MercuryImp *)imp status:(MercuryMediaPlayerStatus)status {
    if ([self.delegate respondsToSelector:@selector(mercury_prerollAdView:playerStatusChanged:)]) {
        [self.delegate mercury_prerollAdView:self playerStatusChanged:status];
    }
}

- (void)mercuryAdViewWillPresentFullScreenModal:(MercuryImp *)imp {
    [_timer pauseTimer];
    [self.adView pause];
}

- (void)mercuryAdViewWillDismissFullScreenModal:(MercuryImp *)imp {
    [_timer resumeTimer];
    [self.adView play];
}

// MARK: ======================= set =======================
- (void)setAdModel:(MercuryAdModel *)adModel {
    _adModel = adModel;
    
    if (_adModel.imp.count <= 0) {
        [self removeFromSuperview];
        return;
    }
    
    [_adView removeFromSuperview];
    [_skipV removeFromSuperview];
    
    _adView = [[MercuryAdView alloc] initAdWithImp:adModel.imp[_impIdx]];
    _adView.handle.showLoading = YES;
    _adView.delegate = self;
    [self addSubview:_adView];
}

// MARK: ======================= get =======================
- (UIView *)skipV {
    if (!_skipV) {
        _skipV = [[UIView alloc] init];
        _skipV.translatesAutoresizingMaskIntoConstraints = NO;
        _skipV.userInteractionEnabled = YES;
        [_skipV addGestureRecognizer:self.skipGesRec];
        _skipV.layer.cornerRadius = 12;
        // 跳过Label
        UILabel *skip01Lbl = [[UILabel alloc] init];
        skip01Lbl.translatesAutoresizingMaskIntoConstraints = NO;
        [_skipV addSubview:skip01Lbl];
        [skip01Lbl.topAnchor constraintEqualToAnchor:_skipV.topAnchor].active = YES;
        [skip01Lbl.leftAnchor constraintEqualToAnchor:_skipV.leftAnchor constant:8].active = YES;
        [skip01Lbl.bottomAnchor constraintEqualToAnchor:_skipV.bottomAnchor].active = YES;
        [skip01Lbl.widthAnchor constraintEqualToConstant:30].active = YES;
        skip01Lbl.textColor = [UIColor whiteColor];
        skip01Lbl.textAlignment = NSTextAlignmentCenter;
        skip01Lbl.font = [UIFont systemFontOfSize:12];
        skip01Lbl.text = @"跳过";
        // 线
        UIView *lineV = [[UIView alloc] init];
        lineV.translatesAutoresizingMaskIntoConstraints = NO;
        [_skipV addSubview:lineV];
        [lineV.topAnchor constraintEqualToAnchor:_skipV.topAnchor constant:5].active = YES;
        [lineV.leftAnchor constraintEqualToAnchor:skip01Lbl.rightAnchor].active = YES;
        [lineV.bottomAnchor constraintEqualToAnchor:_skipV.bottomAnchor constant:-5].active = YES;
        [lineV.widthAnchor constraintEqualToConstant:.5].active = YES;
        lineV.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.6];
        // 时间
        UILabel *skip02Lbl = [[UILabel alloc] init];
        skip02Lbl.translatesAutoresizingMaskIntoConstraints = NO;
        [_skipV addSubview:skip02Lbl];
        [skip02Lbl.topAnchor constraintEqualToAnchor:_skipV.topAnchor].active = YES;
        [skip02Lbl.rightAnchor constraintEqualToAnchor:_skipV.rightAnchor constant:-8].active = YES;
        [skip02Lbl.bottomAnchor constraintEqualToAnchor:_skipV.bottomAnchor].active = YES;
        [skip02Lbl.leftAnchor constraintEqualToAnchor:lineV.rightAnchor].active = YES;
        skip02Lbl.textColor = [UIColor whiteColor];
        skip02Lbl.textAlignment = NSTextAlignmentCenter;
        skip02Lbl.font = [UIFont systemFontOfSize:12];
        _skip02Lbl = skip02Lbl;
//        _skip02Lbl.text = [NSString stringWithFormat:@"%02ld", (long)_adView.totalTime];
    }
    return _skipV;
}

- (UITapGestureRecognizer *)skipGesRec {
    if (!_skipGesRec) {
        _skipGesRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(skpiBtnActionSelf:)];
    }
    return _skipGesRec;
}

@end
