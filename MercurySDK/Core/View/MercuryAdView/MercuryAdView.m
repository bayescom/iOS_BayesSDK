//
//  MercuryAdView.m
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/22.
//  Copyright © 2020 mercury. All rights reserved.
//

#import "MercuryAdView.h"
#import "MercuryAdModel.h"
#import "MercuryPriHeader.h"
#import "MercuryGCDTimer.h"
#import "UIView+Mercury.h"
#import "MercuryPriHeader.h"
#import "MercuryWebViewController.h"
#import "UIWindow+Mercury.h"
#import "UIImage+Mercury.h"
#import "SDWebImageDownloader.h"
#import <StoreKit/StoreKit.h>
#import "UIImageView+WebCache.h"

#import "MercuryPreloadMediaManager.h"
#import "Mercury_FBKVOController.h"

#import "MercuryPlayer.h"
#import "MercuryPlayerControlView.h"
#import "MercuryAVPlayerManager.h"
#import "MercuryReachability.h"

@interface MercuryAdView () <MercuryBaseAdSKVCDelegate, SKStoreProductViewControllerDelegate, MercuryPreloadMediaManagerDelegate> {
    MercuryAdViewVideoHandle *_handle;
}
@property (nonatomic, strong) UIImageView *contentView;
@property (nonatomic, assign) BOOL renderSuccess;

// 广告Imp
@property (nonatomic, strong) MercuryImp *imp;

// 曝光检测
@property (nonatomic, strong) MercuryGCDTimer *exptimer;

// 播放器
@property (nonatomic, strong) MercuryPlayerController *player;
@property (nonatomic, strong) MercuryPlayerControlView *controlView;

// 手势
@property (nonatomic, strong) UILongPressGestureRecognizer *tapGesRec;
// 被注册手势的views
@property (nonatomic, strong) NSMapTable *gestureMap;
// 点击位置临时存放
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGPoint endPoint;

// 广告水印
@property (nonatomic, strong) CATextLayer *sourceLayer;

@property (nonatomic, strong) UIButton *play_pauseBtn;

/// 监听变化
@property (nonatomic, strong) Mercury_FBKVOController *kvo_c;

/// 播放器状态 防止回调多次触发
@property (atomic, assign) MercuryMediaPlayerStatus playStatus;

/// 是否是用户点击引起的暂停
@property (nonatomic, assign) BOOL pauseByUser;

/// 监听网络
@property (nonatomic, strong) MercuryReachability *reach;

/// 视频下载完成
@property (nonatomic, assign) BOOL videoDownloadFinish;

@end

@implementation MercuryAdView

- (instancetype)initAdWithImp:(MercuryImp * _Nonnull)imp {
    return [self initAdWithImp:imp handle:[MercuryAdViewVideoHandle defaultHandle]];
}

- (instancetype)initAdWithImp:(MercuryImp * _Nonnull)imp handle:(MercuryAdViewVideoHandle *)handle {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self loadAdWithImp:imp];
        _handle = handle;
        // 监听值变化
        [self beginHandleObserver];
    }
    return self;
}

- (void)loadAdWithImp:(MercuryImp *)imp {
    if (_imp == imp) { return; }
    _imp = imp;
    _renderSuccess = NO;
    [_exptimer stopTimer];
    [self renderWithSize:self.bounds.size];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)destory {
    [self removeFromSuperview];
    [_kvo_c unobserveAll];
    [_exptimer stopTimer];
    [_player.currentPlayerManager stop];
    _kvo_c = nil;
    _player = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 过滤无效设置
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) { return; }
    _contentView.frame = self.bounds;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    if (_imp.isVideoType) {
        [self setWatermarkWithLayer:self.player.currentPlayerManager.view.layer];
    } else {
        [self setWatermarkWithLayer:_contentView.layer];
    }
    
    _sourceLayer.hidden = _handle.hiddenSource;
    [CATransaction commit];
}

/// 渲染广告
- (void)renderWithSize:(CGSize)size {
    if (CGSizeEqualToSize(CGSizeZero, size)) { return; }
    [_exptimer stopTimer];
    _exptimer = nil;
    _player = nil;
    [_contentView removeFromSuperview];
    _contentView.image = nil;
    _contentView = nil;
    
    @mer_weakify(self);
    if (_imp.isVideoType) {
        // 添加手势
        [self addGestureRecognizer:self.tapGesRec];
        @mer_strongify(self);
        [self initPlayer];
    } else { // 图片广告
        [self addSubview:self.contentView];
        NSURL *url = [NSURL URLWithString:_imp.image.firstObject];
        [self.contentView sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            @mer_strongify(self);
            self->_renderSuccess = YES;
            self->_impSize = image.size;
            // 添加手势
            [self.contentView addGestureRecognizer:self.tapGesRec];
            if ([self.delegate respondsToSelector:@selector(mercuryAdViewAdSourceDidRecevedWithImp:size:)]) {
                [self.delegate mercuryAdViewAdSourceDidRecevedWithImp:self.imp size:image.size];
            }
        }];
    }

    // 曝光检测
    if (!_exptimer) {
        _exptimer = [MercuryGCDTimer timerWithTimeInterval:1/20.0 runBlock:^{
            @mer_strongify(self);
            if (self.renderSuccess &&
                [self mercury_isDisplayedInScreen]) {
                if ([self.delegate respondsToSelector:@selector(mercuryAdViewDidExpressWithImp:)]) {
                    [self.delegate mercuryAdViewDidExpressWithImp:self.imp];
                }
                [self.imp reportWithEventType:MercuryBaseAdRepoTKEventTypeShow resultBlock:nil];
                [self beginExpressTimer];
            } else {
                if (self.imp.isVideoType) {
                    if (self.player.currentPlayerManager.playState != MercuryMediaPlayerStatusPaused) {
                        [self.player.currentPlayerManager pause];
                    }
                }
            }
        }];
    }
}

- (void)beginExpressTimer {
    if (!_reach) {
        _reach = [MercuryReachability reachabilityForInternetConnection];
    }
    // 渲染未成功不开启定时器
    if (!_renderSuccess) { return; }
    // 开启一个新的定时器 检测在父视图的交集
    [_exptimer stopTimer];
    _exptimer = [MercuryGCDTimer timerWithTimeInterval:1/20.0 runBlock:^{
        if (!self.handle.stopAutoExpCheckFlag) {
            if ([self mercury_isDisplayedInSuperViewOffset:0.5]) {
                if (self.player.currentPlayerManager.playState != MercuryPlayerPlayStatePlaying) {
                    // 是否是Stop?
                    if (self.player.currentPlayerManager.playState == MercuryPlayerPlayStatePlayStopped) {
                        if (self.handle.autoResumeEnable) { // 是否要自动续播？
                            [self.player.currentPlayerManager replay];
                        }
                    } else {
                        if (self.handle.videoPlayPolicy == MercuryVideoAutoPlayPolicyNever &&
                            !self.player.currentPlayerManager.isPlaying) {   // 从不自动播放
                            return;
                        }
                        if (self.handle.videoPlayPolicy == MercuryVideoAutoPlayPolicyWIFI &&
                            self.reach.currentReachabilityStatus != MercuryNetworkStatusReachableViaWiFi) {     // 网络不可用检测
                            return;
                        }
                        if (!self.player.currentPlayerManager.isPlaying) {
                            [self.player.currentPlayerManager play];
                        }
                    }
                }
            } else {
                if (self.player.currentPlayerManager.playState == MercuryPlayerPlayStatePlaying) {
                    [self.player.currentPlayerManager pause];
                }
            }
        }
    }];
}

- (void)initPlayer {
    if (!_imp.vurl) {
        if ([_delegate respondsToSelector:@selector(mercuryAdViewAdSourceDidRecevedWithImp:size:)]) {
            [_delegate mercuryAdViewAdSourceDidRecevedWithImp:_imp size:CGSizeZero];
        }
        return;
    }
    
    MercuryAVPlayerManager *playerManager = [[MercuryAVPlayerManager alloc] init];
    /// 播放器相关
    self.player = [MercuryPlayerController playerWithPlayerManager:playerManager containerView:self];
    self.player.controlView = self.controlView;
    @mer_weakify(self);
    [self.controlView setPlayOrPauseBtnClickCallback:^(BOOL isPause) {
        @mer_strongify(self);
        // 用户触发操作停止检测 播放状态继续检测
        self.handle.stopAutoExpCheckFlag = isPause;
    }];
    /// 设置退到后台继续播放
    self.player.currentPlayerManager.shouldAutoPlay = NO;
    self.player.shouldAutoPlay = NO;
//    self.player.disableCache = YES;
//    self.containerView.userInteractionEnabled = NO;
    
    // 默认配置
    _player.currentPlayerManager.muted = _handle.isMuted;
    _controlView.showPlayProgress = _handle.showPlayProgress;
    // 操作手势
    _player.gestureControl.doubleTap.enabled = NO;
    _player.gestureControl.panGR.enabled = NO;
    _player.gestureControl.pinchGR.enabled = NO;
    _player.gestureControl.singleTap.enabled = _handle.userControlEnable;
    _tapGesRec.enabled = !_player.gestureControl.singleTap.enabled;
    
    self.player.assetURL = [NSURL URLWithString:_imp.vurl];

    __weak typeof(self) _self = self;
    /// 状态变更
    [self.player setPlayerLoadStateChanged:^(id<MercuryPlayerMediaPlayback>  _Nonnull asset, MercuryPlayerLoadState loadState) {
        __strong typeof(_self) self = _self;
        if (!self.player) { return; }
        [self refreshStatus:asset];
    }];
    [self.player setPlayerPlayStateChanged:^(id<MercuryPlayerMediaPlayback>  _Nonnull asset, MercuryPlayerPlaybackState playState) {
        __strong typeof(_self) self = _self;
        if (!self.player) { return; }
        [self refreshStatus:asset];
    }];
    /// 时间变更
    [self.player setPlayerPlayTimeChanged:^(id<MercuryPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong typeof(_self) self = _self;
        if (!self.player) { return; }
        self->_impSize = asset.presentationSize;
        
        // 时间变更
        if (asset.currentTime > 0) {
            // 如果才开始播放，且播放策略为不自动播放，触发暂停
            if (!self.renderSuccess &&
                self.handle.videoPlayPolicy == MercuryVideoAutoPlayPolicyNever) {
                [self.player.currentPlayerManager pause];
            }
            if ([self.delegate respondsToSelector:@selector(mercuryAdViewVideoTimeCurrentTime:totalTime:)]) {
                [self.delegate mercuryAdViewVideoTimeCurrentTime:asset.currentTime totalTime:self.imp.duration>0?self.imp.duration:asset.totalTime];
            }
        }
    }];
    /// 视频准备好播放
    [self.player setPlayerReadyToPlay:^(id<MercuryPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        __strong typeof(_self) self = _self;
        self->_impSize = asset.presentationSize;
        if (!self.player) { return; }
        if ([self.delegate respondsToSelector:@selector(mercuryAdViewAdSourceDidRecevedWithImp:size:)]) {
            [self.delegate mercuryAdViewAdSourceDidRecevedWithImp:self.imp size:asset.presentationSize];
        }
        // 尝试播放
        if (self.handle.videoPlayPolicy == MercuryVideoAutoPlayPolicyNever) {
            [self.player.currentPlayerManager pause];
        } else {
            [self.player.currentPlayerManager play];
        }
        /// 视频曝光
        self.renderSuccess = YES;
        /// 下载成功检测
        [self callDownloadFinishCallBack];
    }];
    
    // 下载
    MercuryPreloadMediaManager.manager.delegate = self;
    MercuryPreloadMediaManager.manager.downloadOnWWAN = _downloadOnWWAN;
    [MercuryPreloadMediaManager.manager downloadVideoUrlStr:[_imp.vurl copy]];
}

- (void)setDownloadOnWWAN:(BOOL)downloadOnWWAN {
    _downloadOnWWAN = downloadOnWWAN;
    MercuryPreloadMediaManager.manager.downloadOnWWAN = _downloadOnWWAN;
}

- (void)refreshStatus:(id<MercuryPlayerMediaPlayback> _Nonnull)asset  {
    if (asset.loadState == MercuryPlayerLoadStateUnknown) { // 初始状态
        if (asset.playState == MercuryPlayerPlayStatePlayStopped) {
            self.playStatus = MercuryMediaPlayerStatusStoped;
        } else {
            self.playStatus = MercuryMediaPlayerStatusInitial;
        }
    } else if (asset.loadState == MercuryPlayerLoadStatePrepare) { // 加载中
        self.playStatus = MercuryMediaPlayerStatusLoading;
    } else if (asset.playState == MercuryPlayerPlayStatePlaying) {  // 播放中
        self.playStatus = MercuryMediaPlayerStatusPlaying;
    } else if (asset.playState == MercuryPlayerPlayStatePaused) {  // 已暂停
        self.playStatus = MercuryMediaPlayerStatusPaused;
    } else if (asset.playState == MercuryPlayerPlayStatePlayStopped) {  // 已停止
        self.playStatus = MercuryMediaPlayerStatusStoped;
    } else if (asset.playState == MercuryPlayerPlayStatePlayFailed) {  // 播放出错
        self.playStatus = MercuryPlayerPlayStatePlayFailed;
    }
}

- (void)setWatermarkWithLayer:(CALayer *)a_layer {
    if (_handle.removeWaterMarkFlag) {
        [_sourceLayer removeFromSuperlayer];
        return;
    }
    // 如果创建过sourceLayer，修改一下frame即可
    NSString *string = [NSString stringWithFormat:@" %@ ", _imp.adsource];
    // 文字发生了变化
    if (![_sourceLayer.string isEqual:string]) {
        [_sourceLayer removeFromSuperlayer];
        _sourceLayer = [CATextLayer layer];
        _sourceLayer.contentsScale = [UIScreen mainScreen].scale;
        NSDictionary *dic = @{
            NSFontAttributeName:[UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName:[UIColor whiteColor],
        };
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
        [attributedStr addAttributes:dic range:NSMakeRange(0, string.length)];
        _sourceLayer.string = attributedStr;
        _sourceLayer.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:0.5].CGColor;
        CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 30) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
        if (_imp.isVideoType) { // 视频添加到左下角
            CGFloat real_w = ceil(self.bounds.size.width);
            CGFloat real_h = ceil(self.player.currentPlayerManager.presentationSize.height*(real_w/self.player.currentPlayerManager.presentationSize.width));
            
            CGFloat ofset = a_layer?(a_layer.bounds.size.height-real_h)/2.0:0;
            _sourceLayer.frame = CGRectMake(0, a_layer.bounds.size.height-size.height - self.waterMarkYOffset - ABS(ofset) - (_handle.showPlayProgress?2:0),
                                            size.width, size.height);
        } else if (_contentView.image) {    // 图片添加到素材的左下角(因为图片不会缩放)
            CGFloat real_w = ceil(self.contentView.bounds.size.width);
            CGFloat real_h = ceil(_contentView.image.size.height*(real_w/_contentView.image.size.width));
            _sourceLayer.frame = CGRectMake(0, (a_layer.bounds.size.height-real_h)/2.0 + real_h - size.height - self.waterMarkYOffset, size.width, size.height);
        }
    }
    [a_layer addSublayer:_sourceLayer];
}

/// 添加点击手势
- (void)registAdClickViews:(NSArray *)views {
    for (UIView *a_v in views) {
        a_v.userInteractionEnabled = YES;
        // add gesture to a_v
        UILongPressGestureRecognizer *ges = [_gestureMap objectForKey:a_v];
        if (ges) { continue; }
        ges = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(__AdTapAction:)];
        ges.minimumPressDuration = 0.0;
        ges.allowableMovement  = 10;
        [a_v addGestureRecognizer:ges];
        
        if (!_gestureMap) { _gestureMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory]; }
        [_gestureMap setObject:ges forKey:a_v];
    }
}

/// 移除手势
- (void)unregistAdClickViews:(NSArray *)views {
    for (UIView *a_v in views) {
        UILongPressGestureRecognizer *ges = [_gestureMap objectForKey:a_v];
        if (!ges) { continue; }
        [a_v removeGestureRecognizer:ges];
    }
}

// TODO: 这个手势冲突的问题，挺麻烦
// 广告点击
- (void)__AdTapAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {    // 手指按下
        _beginPoint = MercuryToPixelsFromPoint([sender locationInView:sender.view]);
    } else if (sender.state == UIGestureRecognizerStateEnded) { // 手指抬起
        if (CGRectContainsPoint(sender.view.bounds, [sender locationInView:sender.view])) {
            _endPoint = MercuryToPixelsFromPoint([sender locationInView:sender.view]);
            // 点击逻辑
            if ([_delegate respondsToSelector:@selector(mercuryAdViewDidClickWithImp:)]) {
                [_delegate mercuryAdViewDidClickWithImp:self.imp];
            }
            [self adDidClickWithBeginPoint:_beginPoint endPoint:_endPoint resultBlock:nil];
        }
    }
}

// MARK: ======================= 点击广告逻辑 =======================
- (void)adDidClickWithBeginPoint:(CGPoint)beginPoint
                        endPoint:(CGPoint)endPoint
                     resultBlock:(void (^)(BOOL isSuccess, MercuryBaseAdRepoTKEventType eventType))resultBlock {
    [self.imp reportWithBeginPoint:_beginPoint endPoint:_endPoint resultBlock:resultBlock];
    // 打开推广链接
    UIApplication *application = [UIApplication sharedApplication];
    
    UIViewController *vc = _controller;
    if (!vc) {
        vc = [UIApplication sharedApplication].mercury_getCurrentWindow.mercury_getCurrentActivityViewController;
    }
// MARK: ======================= 打开AppId =======================
//#warning AppleId测试
//    self.imp.appleId = @"1088179585";
//    if (self.imp.appleId) {
//        // SKVC即将显示
//        if ([self.delegate respondsToSelector:@selector(mercuryAdViewWillPresentFullScreenModal:)]) {
//            [self.delegate mercuryAdViewWillPresentFullScreenModal:self.imp];
//        }
//        SKStoreProductViewController * skvc = [[SKStoreProductViewController alloc] init];
//        skvc.delegate = self;
//        [skvc loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:self.imp.appleId}
//                        completionBlock:^(BOOL result, NSError *error) {
//            if (result) {
//                if ([self.delegate respondsToSelector:@selector(mercuryAdViewDidPresentFullScreenModal:)]) {
//                    [self.delegate mercuryAdViewDidPresentFullScreenModal:self.imp];
//                }
//            } else {
//                NSLog(@"%@",error);
//            }
//        }];
//        [vc presentViewController:skvc animated:YES completion:^{}];
//        return;
//    }
    
// MARK: ======================= 打开 link || DeepLink =======================
//
//    adImp.link = @"taobaotravel://";
    
//    adImp.link = @"https://www.nike.com/cn/you-cant-stop-us?cp=cn_brom_041020_a_GEN_AL_RTT_HJ_LM_14_SP_PR";
//    adImp.deeplink = nil;
    
//     使用内部浏览器打开
    if (@available(iOS 10.0, *)) {
        if (self.imp.deeplink && self.imp.deeplink.length > 0) {
            [application openURL:[NSURL URLWithString:self.imp.deeplink] options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    // 如果可以成功打开scheme url
                    [self.imp reportWithEventType:MercuryBaseAdRepoTKEventTypeDeeplink resultBlock:nil];
                } else {
                    // deeplink打开无效 则用Link打开
                    [self.imp reportWithEventType:MercuryBaseAdRepoTKEventTypeLink resultBlock:nil];
                    // 判断链接是否是ulink
                    [application openURL:[NSURL URLWithString:self.imp.link] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@(YES)} completionHandler:^(BOOL success) {
                        if (success) {  // 此ulink可以打开App 直接换起App
                        } else {    // 此链接为普通链接 用浏览器打开
                            [vc presentViewController:[MercuryWebViewController navcWithUrl:self.imp.link delegate:self] animated:YES completion:^{}];
                        }
                    }];
                }
            }];
        } else {    // deeplink不存在 则用Link打开
            [self.imp reportWithEventType:MercuryBaseAdRepoTKEventTypeLink resultBlock:nil];
            // link是否是可用的ulink
            [application openURL:[NSURL URLWithString:self.imp.link] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@(YES)} completionHandler:^(BOOL success) {
                if (success) {} else {  // 此链接为普通链接 用浏览器打开
                    [vc presentViewController:[MercuryWebViewController navcWithUrl:self.imp.link delegate:self] animated:YES completion:^{}];
                }
            }];
        }
    } else {
        if (self.imp.deeplink && self.imp.deeplink.length > 0) {
            if ([application openURL:[NSURL URLWithString:self.imp.deeplink]]) {   // Deeplink
                [self.imp reportWithEventType:MercuryBaseAdRepoTKEventTypeLink resultBlock:nil];
            } else {    // link
                [self.imp reportWithEventType:MercuryBaseAdRepoTKEventTypeLink resultBlock:nil];
                // 浏览器打开
                [vc presentViewController:[MercuryWebViewController navcWithUrl:self.imp.link delegate:self] animated:YES completion:^{}];
            }
        } else {    // link
            [self.imp reportWithEventType:MercuryBaseAdRepoTKEventTypeLink resultBlock:nil];
            [vc presentViewController:[MercuryWebViewController navcWithUrl:self.imp.link delegate:self] animated:YES completion:^{}];
        }
    }
}

// MARK: ======================= MercuryPreloadMediaManagerDelegate =======================
- (void)preloadDownloadSourceSuccess:(NSURL *)url {
    if ([url.absoluteString isEqualToString:_imp.vurl]) {
        _videoDownloadFinish = YES;
        [self callDownloadFinishCallBack];
    }
}

- (void)callDownloadFinishCallBack {
    // 渲染完成 且 下载完成 走下载完成回调
    if (_renderSuccess && _videoDownloadFinish) {
        // 下载完成
        mer_dispatch_main_safe_async(^{
            if ([self.delegate respondsToSelector:@selector(mercuryAdViewVideoLoadProgressWithImp:loadedProgress:)]) {
                [self.delegate mercuryAdViewVideoLoadProgressWithImp:self.imp loadedProgress:1.0];
            }
        });
    }
}

// MARK: ======================= MercuryBaseAdSKVCDelegate =======================
/// 即将弹出全屏广告页
- (void)_mercury_skvcWillPresentFullScreenModal {
    // 视频类型处理
    if (_imp.isVideoType) {
        if (_player.currentPlayerManager.isPlaying) {
            _pauseByUser = YES;
            [_player.currentPlayerManager pause];
        }
    }
    mer_dispatch_main_safe_async(^{
        if ([self.delegate respondsToSelector:@selector(mercuryAdViewWillPresentFullScreenModal:)]) {
            [self.delegate mercuryAdViewWillPresentFullScreenModal:self.imp];
        }
    });
}

/// 已经弹出全屏广告页
- (void)_mercury_skvcDidPresentFullScreenModal {
    mer_dispatch_main_safe_async(^{
        if ([self.delegate respondsToSelector:@selector(mercuryAdViewDidPresentFullScreenModal:)]) {
            [self.delegate mercuryAdViewDidPresentFullScreenModal:self.imp];
        }
    });
}

/// 即将退出全屏广告页
- (void)_mercury_skvcWillDismissFullScreenModal {
    mer_dispatch_main_safe_async(^{
        if ([self.delegate respondsToSelector:@selector(mercuryAdViewWillDismissFullScreenModal:)]) {
            [self.delegate mercuryAdViewWillDismissFullScreenModal:self.imp];
        }
    });
}

/// 已经退出全屏广告页
- (void)_mercury_skvcDidDismissFullScreenModal {
    // 视频类型处理
    if (_imp.isVideoType && _pauseByUser) {
        [_player.currentPlayerManager play];
    }
    mer_dispatch_main_safe_async(^{
        if ([self.delegate respondsToSelector:@selector(mercuryAdViewDidDismissFullScreenModal:)]) {
            [self.delegate mercuryAdViewDidDismissFullScreenModal:self.imp];
        }
    });
}

// MARK: ======================= get =======================
- (UILongPressGestureRecognizer *)tapGesRec {
    if (!_tapGesRec) {
        _tapGesRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(__AdTapAction:)];
        _tapGesRec.minimumPressDuration = 0.0;
        _tapGesRec.allowableMovement  = 10;
    }
    return _tapGesRec;;
}

- (MercuryImp *)curImp {
    return _imp;
}

- (UIImageView *)contentView {
    if (!_contentView) {
        _contentView = [[UIImageView alloc] init];
        _contentView.userInteractionEnabled = YES;
        _contentView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _contentView;
}

- (MercuryPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [MercuryPlayerControlView new];
        _controlView.autoHiddenTimeInterval = 1.5;
        _controlView.prepareShowLoading = YES;
    }
    return _controlView;
}

// 开始监听
- (void)beginHandleObserver {
    if (!_kvo_c) {
        @mer_weakify(self);
        _kvo_c = [Mercury_FBKVOController controllerWithObserver:_handle];
        
        [_kvo_c observe:_handle keyPath:@"muted" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            @mer_strongify(self);
            self.player.muted = [[change objectForKey:@"new"] boolValue];
            NSLog(@"%d", self.player.isMuted);
        }];
        
        [_kvo_c observe:_handle keyPath:@"showPlayProgress" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            @mer_strongify(self);
            self.controlView.showPlayProgress = self.handle.showPlayProgress;
        }];
        
        
        [_kvo_c observe:_handle keyPath:@"hiddenSource" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            @mer_strongify(self);
            self.sourceLayer.hidden = [change objectForKey:@"new"];
        }];
        
        [_kvo_c observe:_handle keyPath:@"removeWaterMarkFlag" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            @mer_strongify(self);
            [self setWatermarkWithLayer:nil];
        }];
        
        [_kvo_c observe:_handle keyPath:@"userControlEnable" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            @mer_strongify(self);
            self.player.gestureControl.singleTap.enabled = self.handle.userControlEnable;
            self.tapGesRec.enabled = !self.player.gestureControl.singleTap.enabled;
        }];
    }
}

@end


@implementation MercuryAdView (Media)

// MARK: ======================= MercuryAdViewVideoHandleDelegate =======================

- (void)play {
    _handle.stopAutoExpCheckFlag = YES;
    [_player.currentPlayerManager play];
}

- (void)pause {
    _handle.stopAutoExpCheckFlag = YES;
    [_player.currentPlayerManager pause];
}

- (void)replay {
    _handle.stopAutoExpCheckFlag = YES;
    [_player.currentPlayerManager replay];
}

- (void)stop {
    _handle.stopAutoExpCheckFlag = YES;
    [_player.currentPlayerManager stop];
}


// MARK: ======================= set =======================

- (void)setPlayStatus:(MercuryMediaPlayerStatus)playStatus {
    if (_playStatus == playStatus) { return; }
    _playStatus = playStatus;
    if ([self.delegate respondsToSelector:@selector(mercuryAdViewVideoStatusChangeWithImp:status:)]) {
        [self.delegate mercuryAdViewVideoStatusChangeWithImp:self.imp status:_playStatus];
    }
}

- (void)setWaterMarkYOffset:(CGFloat)waterMarkYOffset {
    _waterMarkYOffset = waterMarkYOffset;
    
    CALayer *a_layer = self.sourceLayer.superlayer;
    if (!a_layer) { return; }
    CGSize size = self.sourceLayer.bounds.size;
    if (self.imp.isVideoType) { // 视频添加到左下角
        CGFloat real_w = ceil(self.bounds.size.width);
        CGFloat real_h = ceil(self.player.currentPlayerManager.presentationSize.height*(real_w/self.player.currentPlayerManager.presentationSize.width));
        CGFloat ofset = (a_layer.bounds.size.height-real_h)/2.0;
        self.sourceLayer.frame = CGRectMake(0, a_layer.bounds.size.height-size.height - self.waterMarkYOffset - ABS(ofset) - (self.handle.showPlayProgress?2:0),
                                        size.width, size.height);
    } else if (self.contentView.image) {    // 图片添加到素材的左下角(因为图片不会缩放)
        CGFloat real_w = ceil(self.contentView.bounds.size.width);
        CGFloat real_h = ceil(self.contentView.image.size.height*(real_w/self.contentView.image.size.width));
        self.sourceLayer.frame = CGRectMake(0, (a_layer.bounds.size.height-real_h)/2.0 + real_h - size.height - self.waterMarkYOffset, size.width, size.height);
    }
}

// MARK: ======================= get =======================
- (NSTimeInterval)totalTime {
    return _player.totalTime;
}

- (UIButton *)play_pauseBtn {
    if (!_play_pauseBtn) {
        _play_pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_play_pauseBtn setImage:kMercuryImageNamed(@"_mercury_sdk3_0_play") forState:UIControlStateNormal];
        [_play_pauseBtn sizeToFit];
        _play_pauseBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _play_pauseBtn.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:0.5];
    }
    return _play_pauseBtn;
}

- (MercuryAdViewVideoHandle *)handle {
    return _handle;
}

@end
