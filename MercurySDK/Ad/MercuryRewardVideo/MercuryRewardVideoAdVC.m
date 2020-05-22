//
//  MercuryRewardVideoAdVC.m
//  Example
//
//  Created by CherryKing on 2019/11/18.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryRewardVideoAdVC.h"
#import "MercuryCircleontrolView.h"
#import "MercuryAdView.h"
#import "MercuryPriHeader.h"
#import "UIImageView+WebCache.h"
#import "MercuryAdModel.h"
#import "UIWindow+Mercury.h"

@interface MercuryRewardVideoAdVC () <MercuryAdViewDelegate>
@property (nonatomic, strong) MercuryAdView *adView;
@property (nonatomic, strong) MercuryAdModel *adModel;

@property (nonatomic, assign) CGSize impSize;

@property (nonatomic, strong) MercuryCircleontrolView *timeCircleV;
@property (nonatomic, strong) MercuryCircleontrolView *voiceCircleV;
@property (nonatomic, strong) MercuryCircleontrolView *closeCircleV;

@property (nonatomic, strong) NSLayoutConstraint *handleView_btm_cons;
@property (nonatomic, strong) NSLayoutConstraint *adView_h_cons;
@property (nonatomic, strong) NSLayoutConstraint *handle_h_cons;

/// 播放中的下方可点击视图
@property (nonatomic, strong) UIView *handleView;

/// 手势
@property (nonatomic, strong) UITapGestureRecognizer *voicePress;
@property (nonatomic, strong) UITapGestureRecognizer *closePress;

@property (nonatomic, assign) UIInterfaceOrientationMask curOrientation;
@property (nonatomic, assign, readonly) BOOL isPortrait;

/// 广告展示的时间
@property (nonatomic, assign) NSTimeInterval showTime;

@property (nonatomic, assign) BOOL isClick;

@property(nonatomic, copy) void (^completion)(void);

@end

@implementation MercuryRewardVideoAdVC

- (instancetype)initAdWithAdspotId:(NSString *)adspotId appId:(NSString *)appId mediaKey:(NSString *)mediaKey completion: (void (^ _Nullable)(void))completion {
    if (self = [super init]) {
        @mer_weakify(self);
        _completion = completion;
        [MercuryAdModel loadAdWithAdspotId:adspotId
                                     appId:appId
                                  mediaKey:mediaKey
                                fetchDelay:3
                               resultBlock:^(NSError * _Nonnull error, MercuryAdModel * _Nonnull adModel) {
            @mer_strongify(self);
            if (!error) {
                if (![adModel.imp.firstObject checkAdType:MercuryAdModelType06
                                            creativeTypes:@[@(MercuryAdModelCreativeType10)]]) {
                    if ([self.delegate respondsToSelector:@selector(mercury_rewardAdFailError:)]) {
                        [self.delegate mercury_rewardAdFailError:[MercuryError errorWitherror:MercuryResultCode211].toNSError];
                    }
                    return;
                }
                self.adModel = adModel;
                if ([self.delegate respondsToSelector:@selector(mercury_rewardVideoAdDidLoad)]) {
                    [self.delegate mercury_rewardVideoAdDidLoad];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(mercury_rewardAdFailError:)]) {
                    [self.delegate mercury_rewardAdFailError:error];
                }
            }
        }];
    }
    return self;
}

- (void)showFromVC:(UIViewController *)vc {
    if (_adView.renderSuccess) {
        _adView.handle.stopAutoExpCheckFlag = YES;
        [vc presentViewController:self animated:YES completion:nil];
    } else {
        NSLog(@"广告未渲染完成");
    }
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [_adView destory];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _isClick = NO;
//    /// 强制横屏测试
//    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_adView play];
    _adView.handle.stopAutoExpCheckFlag = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_adView) {
        NSLog(@"请重新请求广告");
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    if (!_isClick) {
        _showTime = MIN(_adView.totalTime, _adView.curImp.duration);
        [self applicationLifeCycleNotification];
        [self setSubviewsAutoLayoutWithImp:_adView.curImp size:_impSize];
        if (!_handleView) {
            _handleView = [[UIView alloc] init];
            // 背景
            [self.view addSubview:_handleView];
            _handleView.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:0.8];
            _handleView.translatesAutoresizingMaskIntoConstraints = NO;
            _handleView.layer.cornerRadius = 6;
            _handleView_btm_cons = [_handleView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:200];
            [_handleView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:8].active = YES;
            [_handleView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-8].active = YES;
            _handle_h_cons = [_handleView.heightAnchor constraintEqualToConstant:80];
            _handle_h_cons.active = YES;
            
            _handleView_btm_cons.active = YES;
            _handleView.userInteractionEnabled = YES;
            [_handleView addGestureRecognizer:_adView.tapGesRec];
        }
        
        [_timeCircleV setText:[NSString stringWithFormat:@"%02d", (int)(_showTime)]];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// 屏幕方向(是否竖屏)
- (BOOL)isPortrait {
    return (_curOrientation == UIInterfaceOrientationPortrait || _curOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return NO;
    } else {
        return YES;
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
//    [_adView destory];
//    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)setSubviewsAutoLayoutWithImp:(MercuryImp *)imp size:(CGSize)impSize {
    if (CGSizeEqualToSize(impSize, _adView.bounds.size)) {
        return;
    }
    [self layoutSubviewsWithImpSize:impSize];
}

- (void)layoutSubviewsWithImpSize:(CGSize)impSize {
    CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
    CGFloat real_h = impSize.height*(real_w/impSize.width);
    // 广告内容
    if (_adView) {
        [self.view addSubview:_adView];
        [_adView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
        [_adView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [_adView.widthAnchor constraintEqualToConstant:real_w].active = YES;
        _adView_h_cons = [_adView.heightAnchor constraintEqualToConstant:real_h];
        _adView_h_cons.active = YES;
    }
    
    [self.view addSubview:self.timeCircleV];
    [_timeCircleV.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:kMercury_StatusBarHeight].active = YES;
    [_timeCircleV.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-10].active = YES;
    [_timeCircleV.widthAnchor constraintEqualToConstant:32].active = YES;
    [_timeCircleV.heightAnchor constraintEqualToConstant:32].active = YES;

    [self.view addSubview:self.voiceCircleV];
    [_voiceCircleV.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:kMercury_StatusBarHeight].active = YES;
    [_voiceCircleV.rightAnchor constraintEqualToAnchor:_timeCircleV.leftAnchor constant:-6].active = YES;
    [_voiceCircleV.widthAnchor constraintEqualToConstant:32].active = YES;
    [_voiceCircleV.heightAnchor constraintEqualToConstant:32].active = YES;

    [self.view addSubview:self.closeCircleV];
    [_closeCircleV.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:kMercury_StatusBarHeight].active = YES;
    [_closeCircleV.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:10].active = YES;
    [_closeCircleV.widthAnchor constraintEqualToConstant:32].active = YES;
    [_closeCircleV.heightAnchor constraintEqualToConstant:32].active = YES;
    _closeCircleV.hidden = YES;
    
    [self.view bringSubviewToFront:_handleView];
}

// MARK: ======================= Btn Action =======================
- (void)__VoiceOpenFlag:(UITapGestureRecognizer *)sender {
    self.adView.handle.muted = !self.adView.handle.isMuted;
    _voiceCircleV.centerImage = self.adView.handle.isMuted?kMercuryImageNamed(@"_mercury_sdk3_0_voice_close"):kMercuryImageNamed(@"_mercury_sdk3_0_voice_open");
}

// 视图关闭
- (void)__DismisAdView {
    if ([self.delegate respondsToSelector:@selector(mercury_rewardVideoAdDidClose)]) {
        [self.delegate mercury_rewardVideoAdDidClose];
    }
    [_adView pause];
    @mer_weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @mer_strongify(self);
        [self.adView destory];
        self.adView = nil;
        if (self.completion) { self.completion(); }
    }];
}

// MARK: ======================= MercuryAdViewDelegate =======================
/// 广告内容被点击
- (void)mercuryAdViewDidClickWithImp:(MercuryImp *)imp {
    _isClick = YES;
    if ([self.delegate respondsToSelector:@selector(mercury_rewardVideoAdDidClicked)]) {
        [self.delegate mercury_rewardVideoAdDidClicked];
    }
}

- (void)mercuryAdViewVideoLoadProgressWithImp:(MercuryImp *)imp loadedProgress:(CGFloat)loadedProgress {
    if (loadedProgress >= 1) {
        if ([self.delegate respondsToSelector:@selector(mercury_rewardVideoAdVideoDidLoad)]) {
            [self.delegate mercury_rewardVideoAdVideoDidLoad];
        }
    }
}

/// 广告内容被曝光
- (void)mercuryAdViewDidExpressWithImp:(MercuryImp *)imp {
    if ([_delegate respondsToSelector:@selector(mercury_rewardVideoAdWillVisible)]) {
        [_delegate mercury_rewardVideoAdWillVisible];
    }
    if ([_delegate respondsToSelector:@selector(mercury_rewardVideoAdDidExposed)]) {
        [_delegate mercury_rewardVideoAdDidExposed];
    }
}

/// 广告资源尺寸被获取成功
- (void)mercuryAdViewAdSourceDidRecevedWithImp:(MercuryImp *)imp size:(CGSize)impSize {
    _impSize = impSize;
}

// 时间变更
- (void)mercuryAdViewVideoTimeCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime {
    [_timeCircleV setText:[NSString stringWithFormat:@"%02d", (int)(_showTime-currentTime)]];
    [_timeCircleV setProgress:currentTime/_showTime animated:YES];
    if (_showTime <= 0) { return; } // _showTime未赋值return
    // 播放到最后
    if (currentTime >= _showTime) {
        [self.adView pause];
        @mer_weakify(self);
        [SDWebImageManager.sharedManager loadImageWithURL:[NSURL URLWithString:_adView.curImp.image.firstObject] options:SDWebImageLowPriority context:nil progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            @mer_strongify(self);
            [self buildEndActionView:image];
        }];
    }
    if (currentTime >= 1) {  // 播放到2s 展示可点击内容
        [self buildPlayingActionView];
    }
    
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


- (void)mercuryAdViewVideoStatusChangeWithImp:(MercuryImp *)imp status:(MercuryMediaPlayerStatus)status {
    if (status == MercuryMediaPlayerStatusStoped) {
        if ([_delegate respondsToSelector:@selector(mercury_rewardVideoAdDidRewardEffective)]) {
            [_delegate mercury_rewardVideoAdDidRewardEffective];
        }
        if ([_delegate respondsToSelector:@selector(mercury_rewardVideoAdDidPlayFinish)]) {
            [_delegate mercury_rewardVideoAdDidPlayFinish];
        }
    }
}

- (void)buildPlayingActionView {
    if (self.handleView_btm_cons.constant == -8) { return; }
    self.handleView_btm_cons.constant = -8;
    @mer_weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @mer_strongify(self);
         [self.view layoutIfNeeded];
    }];
    // icon
    UIImageView *iconImgV = [[UIImageView alloc] init];
    [_handleView addSubview:iconImgV];
    iconImgV.translatesAutoresizingMaskIntoConstraints = NO;
    [iconImgV sd_setImageWithURL:[NSURL URLWithString:_adView.curImp.logo] placeholderImage:nil];
    [iconImgV.centerYAnchor constraintEqualToAnchor:_handleView.centerYAnchor].active = YES;
    [iconImgV.leftAnchor constraintEqualToAnchor:_handleView.leftAnchor constant:8].active = YES;
    [iconImgV.widthAnchor constraintEqualToConstant:68].active = YES;
    [iconImgV.heightAnchor constraintEqualToConstant:68].active = YES;
    // title
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [_handleView addSubview:titleLbl];
    titleLbl.text = _adView.curImp.title;
    titleLbl.font = [UIFont systemFontOfSize:16];
    titleLbl.textColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:1.00];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLbl.topAnchor constraintEqualToAnchor:iconImgV.topAnchor constant:4].active = YES;
    [titleLbl.leftAnchor constraintEqualToAnchor:iconImgV.rightAnchor constant:6].active = YES;
    // subtitle
    UILabel *subtitleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [_handleView addSubview:subtitleLbl];
    subtitleLbl.text = _adView.curImp.desc;
    subtitleLbl.font = [UIFont systemFontOfSize:14];
    subtitleLbl.textColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.36 alpha:1.00];
    subtitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [subtitleLbl.bottomAnchor constraintEqualToAnchor:iconImgV.bottomAnchor constant:-4].active = YES;
    [subtitleLbl.leftAnchor constraintEqualToAnchor:iconImgV.rightAnchor constant:6].active = YES;
    // 点击下载
    UILabel *downloadLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [_handleView addSubview:downloadLbl];
    downloadLbl.textAlignment = NSTextAlignmentCenter;
    downloadLbl.text = @"点击下载";
    downloadLbl.layer.cornerRadius = 20;
    downloadLbl.layer.masksToBounds = YES;
    downloadLbl.backgroundColor = [UIColor colorWithRed:0.29 green:0.59 blue:1.00 alpha:1.00];
    downloadLbl.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    downloadLbl.textColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00];
    downloadLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [downloadLbl.centerYAnchor constraintEqualToAnchor:_handleView.centerYAnchor].active = YES;
    [downloadLbl.rightAnchor constraintEqualToAnchor:_handleView.rightAnchor constant:-8].active = YES;
    [downloadLbl.widthAnchor constraintEqualToConstant:100].active = YES;
    [downloadLbl.heightAnchor constraintEqualToConstant:40].active = YES;
    // 广告表情
    UILabel *sourceLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [_handleView addSubview:sourceLbl];
    sourceLbl.text = _adView.curImp.adsource;
    sourceLbl.font = [UIFont systemFontOfSize:12];
    sourceLbl.textColor = [UIColor colorWithRed:0.23 green:0.23 blue:0.24 alpha:1.00];
    sourceLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [sourceLbl.bottomAnchor constraintEqualToAnchor:_handleView.bottomAnchor constant:-4].active = YES;
    [sourceLbl.rightAnchor constraintEqualToAnchor:_handleView.rightAnchor constant:-8].active = YES;
}

- (void)buildEndActionView:(UIImage *)image {
    [_handleView removeFromSuperview];
    for (UIView *a_v in _handleView.subviews) { [a_v removeFromSuperview]; }
    _handleView.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:0.8];
    _handleView.userInteractionEnabled = YES;
    [_handleView addGestureRecognizer:self.adView.tapGesRec];
    [self.view addSubview:_handleView];
    
    _closeCircleV.hidden = NO;
    _timeCircleV.hidden = YES;
    _voiceCircleV.hidden = YES;
    _handle_h_cons.constant = self.view.bounds.size.height-kMercury_SafeTopH-kMercury_SafeBottomH;
    [_handleView.widthAnchor constraintEqualToConstant:self.view.bounds.size.width].active = YES;
    [_handleView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_handleView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    [self.view bringSubviewToFront:_closeCircleV];
    
    // title
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [_handleView addSubview:titleLbl];
    titleLbl.text = _adView.curImp.title;
    titleLbl.font = [UIFont systemFontOfSize:20];
    titleLbl.textColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLbl.centerXAnchor constraintEqualToAnchor:_handleView.centerXAnchor].active = YES;
    [titleLbl.centerYAnchor constraintEqualToAnchor:_handleView.centerYAnchor].active = YES;
    // icon
    UIImageView *iconImgV = [[UIImageView alloc] init];
    [_handleView addSubview:iconImgV];
    iconImgV.translatesAutoresizingMaskIntoConstraints = NO;
    [iconImgV sd_setImageWithURL:[NSURL URLWithString:_adView.curImp.logo] placeholderImage:nil];
    [iconImgV.centerXAnchor constraintEqualToAnchor:_handleView.centerXAnchor].active = YES;
    [iconImgV.bottomAnchor constraintEqualToAnchor:titleLbl.topAnchor constant:-10].active = YES;
    [iconImgV.widthAnchor constraintEqualToConstant:80].active = YES;
    [iconImgV.heightAnchor constraintEqualToConstant:80].active = YES;
    // subtitle
    UILabel *subtitleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [_handleView addSubview:subtitleLbl];
    subtitleLbl.text = _adView.curImp.desc;
    subtitleLbl.font = [UIFont systemFontOfSize:16];
    subtitleLbl.textColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.00];
    subtitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [subtitleLbl.centerXAnchor constraintEqualToAnchor:_handleView.centerXAnchor].active = YES;
    [subtitleLbl.topAnchor constraintEqualToAnchor:titleLbl.bottomAnchor constant:8].active = YES;
    // 点击下载
    UILabel *downloadLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [_handleView addSubview:downloadLbl];
    downloadLbl.textAlignment = NSTextAlignmentCenter;
    downloadLbl.text = @"点击下载";
    downloadLbl.layer.cornerRadius = 24;
    downloadLbl.layer.masksToBounds = YES;
    downloadLbl.backgroundColor = [UIColor colorWithRed:0.29 green:0.59 blue:1.00 alpha:1.00];
    downloadLbl.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    downloadLbl.textColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00];
    downloadLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [downloadLbl.centerXAnchor constraintEqualToAnchor:_handleView.centerXAnchor].active = YES;
    [downloadLbl.topAnchor constraintEqualToAnchor:subtitleLbl.bottomAnchor constant:10].active = YES;
    [downloadLbl.widthAnchor constraintEqualToConstant:160].active = YES;
    [downloadLbl.heightAnchor constraintEqualToConstant:48].active = YES;
    // 广告标签
    UILabel *sourceLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [_handleView addSubview:sourceLbl];
    sourceLbl.text = _adView.curImp.adsource;
    sourceLbl.font = [UIFont systemFontOfSize:12];
    sourceLbl.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:1.00];
    sourceLbl.textColor = [UIColor whiteColor];
    sourceLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [sourceLbl.bottomAnchor constraintEqualToAnchor:_handleView.bottomAnchor].active = YES;
    [sourceLbl.rightAnchor constraintEqualToAnchor:_handleView.rightAnchor].active = YES;
}

// MARK: ======================= set =======================
- (void)setAdModel:(MercuryAdModel *)adModel {
    _adModel = adModel;
    if (_adModel.imp.count <= 0) {
        return;
    }
    
    [_adView removeFromSuperview];
    
    _adView = [[MercuryAdView alloc] initAdWithImp:adModel.imp.firstObject];
    _adView.handle.removeWaterMarkFlag = YES;
    _adView.downloadOnWWAN = YES;
    _adView.userInteractionEnabled = NO;    // 激励视频不允许点击
    _adView.delegate = self;
    [_adView renderWithSize:self.view.bounds.size];
}

// MARK: ======================= get =======================
- (MercuryCircleontrolView *)timeCircleV {
    if (!_timeCircleV) {
        _timeCircleV = [[MercuryCircleontrolView alloc] initWithFrame:CGRectZero];
        _timeCircleV.progressBarWidth = 2;
        _timeCircleV.startAngle = -90;
        _timeCircleV.backgroundColor = [UIColor clearColor];
        _timeCircleV.progressBarTrackColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.36 alpha:1.00];
        _timeCircleV.progressBarProgressColor = [UIColor colorWithRed:0.81 green:0.81 blue:0.81 alpha:1.00];
        _timeCircleV.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _timeCircleV;
}

- (MercuryCircleontrolView *)voiceCircleV {
    if (!_voiceCircleV) {
        _voiceCircleV = [[MercuryCircleontrolView alloc] initWithFrame:CGRectZero];
        _voiceCircleV.progressBarWidth = 2;
        _voiceCircleV.backgroundColor = [UIColor clearColor];
        _voiceCircleV.translatesAutoresizingMaskIntoConstraints = NO;
        _voiceCircleV.progressBarTrackColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.36 alpha:1.00];
        _voiceCircleV.progressBarProgressColor = [UIColor colorWithRed:0.81 green:0.81 blue:0.81 alpha:1.00];
        _voiceCircleV.centerImage = kMercuryImageNamed(@"_mercury_sdk3_0_voice_open");
        if (!_voicePress) {
            // 跳过按钮点击
            _voicePress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__VoiceOpenFlag:)];
            [_voiceCircleV addGestureRecognizer:_voicePress];
            // 设置一下默认是否静音
            self.adView.handle.muted = !self.adView.handle.isMuted;
        }
    }
    return _voiceCircleV;
}

- (MercuryCircleontrolView *)closeCircleV {
    if (!_closeCircleV) {
        _closeCircleV = [[MercuryCircleontrolView alloc] initWithFrame:CGRectZero];
        _closeCircleV.progressBarWidth = 2;
        _closeCircleV.backgroundColor = [UIColor clearColor];
        _closeCircleV.translatesAutoresizingMaskIntoConstraints = NO;
        _closeCircleV.progressBarTrackColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.36 alpha:1.00];
        _closeCircleV.progressBarProgressColor = [UIColor colorWithRed:0.81 green:0.81 blue:0.81 alpha:1.00];
        _closeCircleV.centerImage = kMercuryImageNamed(@"_mercury_sdk3_0_close");
        if (!_closePress) {
            // 跳过按钮点击
            _closePress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__DismisAdView)];
            [_closeCircleV addGestureRecognizer:_closePress];
        }
    }
    return _closeCircleV;
}

@end
