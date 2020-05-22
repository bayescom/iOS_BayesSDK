//
//  MercuryNativeAdView.m
//  MercurySDKExample
//
//  Created by CherryKing on 2020/5/7.
//  Copyright © 2020 mercury. All rights reserved.
//

#import "MercuryNativeAdView.h"
#import "MercuryNativeExpressAd.h"
#import "MercuryAdModel.h"
#import "MercuryPriHeader.h"
#import "MercuryAdView.h"
#import "UIImageView+WebCache.h"

//static const CGFloat kNativeExpressMarg = 6;
//static const CGFloat kNativeExpressPadd = 4;
//static const CGFloat kNativeExpressCloseBWH = 20;
#define kNativeExpressFontScale(this_w) ((this_w/[UIScreen mainScreen].bounds.size.width)>0.8?(this_w/[UIScreen mainScreen].bounds.size.width):0.8)

@interface MercuryNativeAdView () <MercuryAdViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) MercuryAdViewVideoHandle *adViewHandle;
@property (nonatomic, strong) MercuryImp *imp;
@property (nonatomic, strong) MercuryAdView *adView;


@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSLayoutConstraint *adViewAnchorH;

// 点击位置临时存放
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGPoint endPoint;

@end

@implementation MercuryNativeAdView

- (instancetype)initAdWithImp:(MercuryImp * _Nonnull)imp size:(CGSize)size {
    if (self = [super init]) {
        _imp = imp;
        _size = size;
        
        _adView = [[MercuryAdView alloc] initAdWithImp:_imp handle:[MercuryAdViewVideoHandle defaultHandle]];

        self.layer.masksToBounds = YES;
        _adView.delegate = self;
        
        _adView.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)dealloc {
    [self.adView destory];
    self.adView = nil;
}

- (void)render {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _size.width, _size.height);
    [_adView renderWithSize:_size];
}

- (void)registAdClickViews:(NSArray *)views {
    [_adView registAdClickViews:views];
}

- (void)unregistAdClickViews:(NSArray *)views {
    [_adView unregistAdClickViews:views];
}

// 广告点击
- (void)__AdTapAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {    // 手指按下
        _beginPoint = MercuryToPixelsFromPoint([sender locationInView:sender.view]);
    } else if (sender.state == UIGestureRecognizerStateEnded) { // 手指抬起
        if (CGRectContainsPoint(sender.view.bounds, [sender locationInView:sender.view])) {
            _endPoint = MercuryToPixelsFromPoint([sender locationInView:sender.view]);
            
//            // MercuryVideoAutoPlayPolicyNever 且 暂停状态下 先开始播放
//            if (_imp.isVideoType &&
//                (_player.assetStatus == BYSJPlaybackTimeControlStatusPaused || BYSJPlaybackTimeControlStatusWaitingToPlay)) {
//                [_player play];
//                self.exptimer = [MercuryGCDTimer timerWithTimeInterval:1/20.0 runBlock:^{
//                    if (!self.handle.stopAutoExpCheckFlag) {
//                        if (![self mercury_isDisplayedInSuperViewOffset:0.5]) {
//                            [self.player pause];
//                            self.exptimer = nil;
//                        }
//                    }
//                }];
//                return;
//            }
//            // 点击逻辑
//            if ([_delegate respondsToSelector:@selector(mercuryAdViewDidClickWithImp:)]) {
//                [_delegate mercuryAdViewDidClickWithImp:self.imp];
//            }
//            [self adDidClickWithBeginPoint:_beginPoint endPoint:_endPoint resultBlock:nil];
        }
    }
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
//    [_adView destory];
}

- (void)layoutSubviewsWithImpSize:(CGSize)impSize {
    if (!_adView && CGSizeEqualToSize(CGSizeZero, impSize)) {
//        if ([self.delegate respondsToSelector:@selector(mercury_nativeExpressAdViewRenderFail:)]) {
//            [self.delegate mercury_nativeExpressAdViewRenderFail:self];
//        }
        [self.adView destory];
        self.adView = nil;
        return;
    }
//    [self addGestureRecognizer:_adView.tapGesRec];
//    _adView.tapGesRec.delegate = self;
    
    CGFloat real_w = _size.width;
    CGFloat real_h = impSize.height*(real_w/impSize.width);
    // 广告内容
    [self addSubview:_adView];
    [_adView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0].active = YES;
    [_adView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0].active = YES;
    [_adView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:0].active = YES;
    if (!_adViewAnchorH) {
        _adViewAnchorH = [_adView.heightAnchor constraintEqualToConstant:real_h];
    } else {
        _adViewAnchorH.constant = real_h;
    }
    _adViewAnchorH.active = YES;
    
    [self layoutIfNeeded];
    _isReady = YES;
    if (_adSizeMode == MercuryNativeExpressAdSizeModeAutoSize) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(_adView.frame));
    }
}

// MARK: ======================= MercuryAdViewDelegate =======================
/// 广告内容被点击
- (void)mercuryAdViewDidClickWithImp:(MercuryImp *)imp {
    if ([self.delegate respondsToSelector:@selector(mercury_nativeAdViewDidClick:)]) {
        [self.delegate mercury_nativeAdViewDidClick:self];
    }
}

/// 广告内容被曝光
- (void)mercuryAdViewDidExpressWithImp:(MercuryImp *)imp {
    if ([self.delegate respondsToSelector:@selector(mercury_nativeAdViewWillExpose:)]) {
        [self.delegate mercury_nativeAdViewWillExpose:self];
    }
}

/// 广告资源尺寸被获取成功
- (void)mercuryAdViewAdSourceDidRecevedWithImp:(MercuryImp *)imp size:(CGSize)impSize {
    [self layoutSubviewsWithImpSize:impSize];
    if ([self.delegate respondsToSelector:@selector(mercury_nativeAdViewRenderSuccess:adSize:)]) {
        [self.delegate mercury_nativeAdViewRenderSuccess:self adSize:impSize];
    }
}

// MARK: ======================= MercuryNativeExpressAdViewDelegate =======================
/// 原生模板视频广告 player 播放状态更新回调
- (void)mercury_nativeExpressAdView:(MercuryNativeExpressAdView *)nativeExpressAdView playerStatusChanged:(MercuryMediaPlayerStatus)status {
    
}

// MARK: ======================= UIGestureRecognizerDelegate =======================
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    if ([touch.view isDescendantOfView:self.adView] &&
        self.adView.curImp.isVideoType &&
        self.adView.handle.userControlEnable) {
        // 如果是可操作的视频视图
        return NO;
    }
    return YES;
}

// MARK: ======================= get =======================
- (MercuryAdViewVideoHandle *)handle {
    return _adView.handle;
}

@end
