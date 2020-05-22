//
//  MercurySplashAdView.m
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/22.
//  Copyright © 2020 mercury. All rights reserved.
//

#import "MercurySplashAdView.h"
#import "MercuryAdView.h"
#import "MercuryAdModel.h"
#import "MercuryPriHeader.h"
#import "MercuryGCDTimer.h"
#import "UIView+Mercury.h"
#import "MercuryDeviceInfoUtil.h"

@interface MercurySplashAdView () <MercuryAdViewDelegate>
@property (nonatomic, strong) MercuryAdView *adView;
@property (nonatomic, strong) MercuryAdModel *adModel;

@property (nonatomic, strong) UIView *skipV;
@property (nonatomic, assign) NSInteger skipTime;
@property (nonatomic, strong) UITapGestureRecognizer *skipGesRec;
@property (nonatomic, strong) NSLayoutConstraint *adViewAnchorH;
@property (nonatomic, strong) UILabel *skip02Lbl;   // 时间变动的Label

@property (nonatomic, strong) UIImageView *placeholderImageView;

@property (nonatomic, strong) UIImageView *bottomLogoImageV;

@property (nonatomic, strong) MercuryGCDTimer *timer;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, copy) NSString *adspotId;
@property (nonatomic, assign) NSTimeInterval fetchDelay;

/// 判断是否被用户点击跳过了
@property (nonatomic, assign) BOOL exposuredSuccessdOrError;

@end

@implementation MercurySplashAdView

- (instancetype)initAdWithAdspotId:(NSString *)adspotId fetchDelay:(NSTimeInterval)fetchDelay {
    if (self = [super init]) {
        self.adspotId = adspotId;
        self.fetchDelay = fetchDelay;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self applicationLifeCycleNotification];
    [self addSubview:self.placeholderImageView];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    // 曝光超时检测
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.fetchDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 判断是否正常曝光
        if (self.adView &&
            !self.exposuredSuccessdOrError &&
            ![self.adView mercury_isDisplayedInSuperViewOffset:0.8]) {
            if ([self.delegate respondsToSelector:@selector(mercury_splashAdFailError:)]) {
                [self.delegate mercury_splashAdFailError:[MercuryError errorWitherror:MercuryResultCode300].toNSError];
            }
            if (self.dismissBlock) { self.dismissBlock(); }
            [self removeFromSuperview];
            [self.adView destory];
            self.adView = nil;
        }
    });
}

- (void)dissmissSelf {
    if (_dismissBlock) { _dismissBlock(); }
    if ([_delegate respondsToSelector:@selector(mercury_splashAdWillClosed:)]) {
        [_delegate mercury_splashAdWillClosed:_ad];
    }
    [_adView destory];
    if ([_delegate respondsToSelector:@selector(mercury_splashAdClosed:)]) {
        [_delegate mercury_splashAdClosed:_ad];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _placeholderImageView.frame = self.bounds;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}

- (void)renderWithSize:(CGSize)size {
    _size = size;
    [MercuryAdModel loadAdWithAdspotId:_adspotId
                                 appId:MercuryDeviceInfoUtil.sharedInstance.appId
                              mediaKey:MercuryDeviceInfoUtil.sharedInstance.mediaKey
                            fetchDelay:_fetchDelay
                           resultBlock:^(NSError * _Nonnull error, MercuryAdModel * _Nonnull adModel) {
        if (!error) {
            if (![adModel.imp.firstObject checkAdType:MercuryAdModelType01
                                        creativeTypes:@[@(MercuryAdModelCreativeType01), @(MercuryAdModelCreativeType02)]]) {
                if ([self.delegate respondsToSelector:@selector(mercury_splashAdFailError:)]) {
                    [self.delegate mercury_splashAdFailError:[MercuryError errorWitherror:MercuryResultCode211].toNSError];
                }
                if (self.dismissBlock) { self.dismissBlock(); }
                [self removeFromSuperview];
                [self.adView destory];
                self.adView = nil;
                return;
            }
            self.adModel = adModel;
        } else {
            if ([self.delegate respondsToSelector:@selector(mercury_splashAdFailError:)]) {
                [self.delegate mercury_splashAdFailError:error];
            }
            if (self.dismissBlock) { self.dismissBlock(); }
            self.exposuredSuccessdOrError = YES;
            [self removeFromSuperview];
        }
    }];
}

- (void)layoutSubviewsWithImpSize:(CGSize)impSize {
    if (!_adView && CGSizeEqualToSize(CGSizeZero, impSize)) {
        if ([self.delegate respondsToSelector:@selector(mercury_splashAdFailError:)]) {
            [self.delegate mercury_splashAdFailError:[MercuryError errorWitherror:MercuryResultCode300].toNSError];
        }
        if (self.dismissBlock) { self.dismissBlock(); }
        [self.adView destory];
        self.adView = nil;
        return;
    }
    
    // 素材尺寸转换为正常尺寸
    CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
    CGFloat real_h = ceil(impSize.height*(real_w/impSize.width));
    
    // 广告内容
    [self addSubview:_adView];
    [_adView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0].active = YES;
    [_adView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [_adView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    _adViewAnchorH = [_adView.heightAnchor constraintEqualToConstant:[UIScreen mainScreen].bounds.size.height];
    _adViewAnchorH.active = YES;
    [self addSubview:self.skipV];
    
    // 跳过按钮
    if (_skipView) {    // 有自定义skipView
        _skipView.userInteractionEnabled = YES;
        [_skipView addGestureRecognizer:self.skipGesRec];
    } else {
        [_skipV.topAnchor constraintEqualToAnchor:self.topAnchor constant:kMercury_StatusBarHeight+8].active = YES;
        [_skipV.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-10].active = YES;
        [_skipV.heightAnchor constraintEqualToConstant:32.0].active = YES;
        [_skipV.widthAnchor constraintEqualToConstant:80.0].active = YES;

        _skipV.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:0.8];
    }
    
    if (!(_logoImage || _bottomView)) {  // 如果Logo或_bottomView不存在
        _adViewAnchorH.constant = [UIScreen mainScreen].bounds.size.height;
    } else {
        UIView *this_view = _bottomView;
        // 如果没有自定义View
        if (!this_view) {
            this_view = self.bottomLogoImageV;
            [self addSubview:_bottomLogoImageV];
        }
        
        // 底部需要的高度
        CGFloat bottom_h = _logoImage.size.height*(ceil([UIScreen mainScreen].bounds.size.width)/_logoImage.size.width);
        if (_bottomView) { bottom_h = _bottomView.bounds.size.height; }
        
        // 除去Logo高度 是否够素材展示?
        if (real_h + bottom_h <= [UIScreen mainScreen].bounds.size.height) {    // 屏幕足够展示 正常展示
            [self addSubview:this_view];
            if (_bottomView) {
                _bottomView.frame = CGRectMake(_bottomView.frame.origin.x, real_h, _bottomView.bounds.size.width, _bottomView.bounds.size.height);
            } else {
                [_bottomLogoImageV.topAnchor constraintEqualToAnchor:_adView.bottomAnchor].active = YES;
                [_bottomLogoImageV.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
                [_bottomLogoImageV.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
                [_bottomLogoImageV.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
            }
            _adViewAnchorH.constant = real_h;
        } else {    // 不够 判断当前showType
            if (_showType == MercurySplashAdShowDefault) { // 默认模式 隐藏Logo & _bottomView
                [this_view removeFromSuperview];
                _adViewAnchorH.constant = [UIScreen mainScreen].bounds.size.height;
            } else if (_showType == MercurySplashAdShowCutBottom) { // 强制展示Logo & _bottomView
                if (_bottomView) {
                    _bottomView.frame = CGRectMake(_bottomView.frame.origin.x,
                                                   [UIScreen mainScreen].bounds.size.height - _bottomView.bounds.size.height,
                                                   _bottomView.bounds.size.width, _bottomView.bounds.size.height);
                    // 遮盖一下底部区域
                    CALayer *covLayer = [[CALayer alloc] init];
                    covLayer.frame = CGRectMake(_bottomView.frame.origin.x,
                                                [UIScreen mainScreen].bounds.size.height - _bottomView.bounds.size.height,
                                                [UIScreen mainScreen].bounds.size.width, _bottomView.bounds.size.height);
                    covLayer.backgroundColor = [UIColor whiteColor].CGColor;
                    [_adView.layer addSublayer:covLayer];
                } else {[_bottomLogoImageV.heightAnchor constraintEqualToConstant:bottom_h].active = YES;
                    [_bottomLogoImageV.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
                    [_bottomLogoImageV.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
                    [_bottomLogoImageV.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
                }
            }
            [self layoutIfNeeded];
            _adView.waterMarkYOffset = this_view.bounds.size.height;
        }
    }

    if (_bottomView) {
        [_bottomLogoImageV removeFromSuperview];
        [self addSubview:_bottomView];
    }
    if (_skipView) {
        [_skipV removeFromSuperview];
        [self addSubview:_skipView];
    }
    [self sendSubviewToBack:self.adView];
}

// 跳过按钮
- (void)skpiBtnActionSelf:(UITapGestureRecognizer *)gesture {
    if ([_delegate respondsToSelector:@selector(mercury_splashAdSkipClicked:)]) {
        [_delegate mercury_splashAdSkipClicked:_ad];
    }
    [_timer stopTimer];
    [_adView destory];
    [self removeFromSuperview];
    [self dissmissSelf];
}

// MARK: ======================= MercuryAdViewDelegate =======================
/// 广告内容被点击
- (void)mercuryAdViewDidClickWithImp:(MercuryImp *)imp {
    [_timer stopTimer];
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(mercury_splashAdClicked:)]) {
        [self.delegate mercury_splashAdClicked:self.ad];
    }
    [self dissmissSelf];
}

/// 广告内容被曝光
- (void)mercuryAdViewDidExpressWithImp:(MercuryImp *)imp {
    if (_timer) { return; }
    if ([_delegate respondsToSelector:@selector(mercury_splashAdExposured:)]) {
        [_delegate mercury_splashAdExposured:_ad];
    }
    if ([_delegate respondsToSelector:@selector(mercury_splashAdSuccessPresentScreen:)]) {
        [_delegate mercury_splashAdSuccessPresentScreen:_ad];
    }
    _exposuredSuccessdOrError = YES;
    @mer_weakify(self);
    _timer = [MercuryGCDTimer timerWithTimeInterval:1 runBlock:^{
        @mer_strongify(self);
        if ([self.delegate respondsToSelector:@selector(mercury_splashAdLifeTime:)]) {
            [self.delegate mercury_splashAdLifeTime:self.skipTime];
        }
        if (self.skipTime <= 0) {
            [self removeFromSuperview];
            [self dissmissSelf];
            [self.timer stopTimer];
        }
        self.skip02Lbl.text = [NSString stringWithFormat:@"%02ld", (long)self.skipTime--];
    }];
}

/// 广告资源尺寸被获取成功
- (void)mercuryAdViewAdSourceDidRecevedWithImp:(MercuryImp *)imp size:(CGSize)impSize {
    // 开始布局
    [self layoutSubviewsWithImpSize:impSize];
    _adView.handle.stopAutoExpCheckFlag = NO;
    [_placeholderImageView removeFromSuperview];
    _placeholderImageView = nil;
}

/// 时间变更
- (void)mercuryAdViewVideoTimeCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime {
    if (ceil(currentTime) == 1) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideoStart resultBlock:nil];
    }
    if (ceil(currentTime) == ceil(totalTime*0.5)) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideoMid resultBlock:nil];
    }
    if (ceil(currentTime) >= ceil(totalTime)) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideoEnd resultBlock:nil];
    }
}

// MARK: ======================= Notification =======================
// 进入后台的通知
- (void)applicationLifeCycleNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidBecomeActive {
    
}

- (void)applicationDidEnterBackground {
    if ([_delegate respondsToSelector:@selector(mercury_splashAdApplicationWillEnterBackground:)]) {
        [_delegate mercury_splashAdApplicationWillEnterBackground:_ad];
    }
    [_timer stopTimer];
    [self removeFromSuperview];
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
    
    MercuryAdViewVideoHandle *handel = [MercuryAdViewVideoHandle defaultHandle];
    handel.muted = YES;
    _adView = [[MercuryAdView alloc] initAdWithImp:adModel.imp.firstObject handle:handel];
    _adView.controller = _controller;
    _skipTime = _adView.curImp.duration<=0?:5;
    _adView.delegate = self;
    
    [_adView renderWithSize:_size];
    
    if ([_delegate respondsToSelector:@selector(mercury_splashAdDidLoad:)]) {
        [_delegate mercury_splashAdDidLoad:_ad];
    }
}

- (void)setController:(UIViewController *)controller {
    _controller = controller;
    _adView.controller = _controller;
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    self.placeholderImageView.image = _placeholderImage;
}

// MARK: ======================= get =======================
- (UIView *)skipV {
    if (!_skipV) {
        _skipV = [[UIView alloc] init];
        _skipV.translatesAutoresizingMaskIntoConstraints = NO;
        _skipV.userInteractionEnabled = YES;
        [_skipV addGestureRecognizer:self.skipGesRec];
        _skipV.layer.cornerRadius = 16;
        // 跳过Label
        UILabel *skip01Lbl = [[UILabel alloc] init];
        skip01Lbl.translatesAutoresizingMaskIntoConstraints = NO;
        [_skipV addSubview:skip01Lbl];
        [skip01Lbl.topAnchor constraintEqualToAnchor:_skipV.topAnchor].active = YES;
        [skip01Lbl.leftAnchor constraintEqualToAnchor:_skipV.leftAnchor constant:8].active = YES;
        [skip01Lbl.bottomAnchor constraintEqualToAnchor:_skipV.bottomAnchor].active = YES;
        [skip01Lbl.widthAnchor constraintEqualToConstant:36].active = YES;
        skip01Lbl.textColor = [UIColor whiteColor];
        skip01Lbl.textAlignment = NSTextAlignmentCenter;
        skip01Lbl.font = [UIFont systemFontOfSize:14];
        skip01Lbl.text = @"跳过";
        // 线
        UIView *lineV = [[UIView alloc] init];
        lineV.translatesAutoresizingMaskIntoConstraints = NO;
        [_skipV addSubview:lineV];
        [lineV.topAnchor constraintEqualToAnchor:_skipV.topAnchor constant:8].active = YES;
        [lineV.leftAnchor constraintEqualToAnchor:skip01Lbl.rightAnchor].active = YES;
        [lineV.bottomAnchor constraintEqualToAnchor:_skipV.bottomAnchor constant:-8].active = YES;
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
        skip02Lbl.font = [UIFont systemFontOfSize:14];
        _skip02Lbl = skip02Lbl;
        _skip02Lbl.text = @"05";
    }
    return _skipV;
}

- (UITapGestureRecognizer *)skipGesRec {
    if (!_skipGesRec) {
        _skipGesRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(skpiBtnActionSelf:)];
    }
    return _skipGesRec;
}

- (UIImageView *)bottomLogoImageV {
    if (!_bottomLogoImageV) {
        _bottomLogoImageV = [[UIImageView alloc] init];
        _bottomLogoImageV.image = _logoImage;
        _bottomLogoImageV.contentMode = UIViewContentModeScaleAspectFit;
        _bottomLogoImageV.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _bottomLogoImageV;
}

- (UIImageView *)placeholderImageView {
    if (!_placeholderImageView) {
        _placeholderImageView = [[UIImageView alloc] init];
        _placeholderImageView.image = _placeholderImage;
    }
    return _placeholderImageView;
}

@end
