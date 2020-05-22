//
//  MercuryNativeExpressAdView.m
//  Example
//
//  Created by CherryKing on 2019/12/13.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryNativeExpressAdView.h"
#import "MercuryNativeExpressAd.h"
#import "MercuryAdModel.h"
#import "MercuryPriHeader.h"
#import "MercuryAdView.h"
#import "UIImageView+WebCache.h"

static const CGFloat kNativeExpressMarg = 6;
static const CGFloat kNativeExpressPadd = 4;
static const CGFloat kNativeExpressCloseBWH = 20;
#define kNativeExpressFontScale(this_w) ((this_w/[UIScreen mainScreen].bounds.size.width)>0.8?(this_w/[UIScreen mainScreen].bounds.size.width):0.8)

@interface MercuryNativeExpressAdView () <MercuryAdViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) MercuryImp *imp;
@property (nonatomic, strong) MercuryAdView *adView;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSLayoutConstraint *adViewAnchorH;

@property (nonatomic, weak) UIView *closeBtn;

@end

@implementation MercuryNativeExpressAdView

- (instancetype)initAdWithImp:(MercuryImp * _Nonnull)imp size:(CGSize)size {
    if (self = [super init]) {
        _imp = imp;
        _size = size;
        
        _adView = [[MercuryAdView alloc] initAdWithImp:_imp];
        _adView.handle.showPlayProgress = YES;
        _adView.handle.showPlayAndPause = YES;
        _adView.handle.autoResumeEnable = YES;
        self.layer.masksToBounds = YES;
        _adView.delegate = self;
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

- (void)removeFromSuperview {
    [super removeFromSuperview];
//    [_adView destory];
}

- (void)layoutSubviewsWithImpSize:(CGSize)impSize {
    if (!_adView && CGSizeEqualToSize(CGSizeZero, impSize)) {
        if ([self.delegate respondsToSelector:@selector(mercury_nativeExpressAdViewRenderFail:)]) {
            [self.delegate mercury_nativeExpressAdViewRenderFail:self];
        }
        [self.adView destory];
        self.adView = nil;
        return;
    }
    _imp.template_id = MercuryNativeExpressAdViewType02;
    [self addGestureRecognizer:_adView.tapGesRec];
    _adView.tapGesRec.delegate = self;
    if (_imp.template_id == MercuryNativeExpressAdViewType00) { /// 上图下文
        [self setlayout_00WithImpSize:impSize];
    } else if (_imp.template_id == MercuryNativeExpressAdViewType01) {  /// 上文下图
        [self setlayout_01WithImpSize:impSize];
    } else if (_imp.template_id == MercuryNativeExpressAdViewType02) {  /// 左图右文
        [self setlayout_02WithImpSize:impSize];
    } else if (_imp.template_id == MercuryNativeExpressAdViewType03) {  /// 左文右图
        [self setlayout_03WithImpSize:impSize];
    } else if (_imp.template_id == MercuryNativeExpressAdViewType04) {  /// 双图单文
        [self setlayout_04WithImpSize:impSize];
    }
}

- (void)viewClick {
    if ([self.delegate respondsToSelector:@selector(mercury_nativeExpressAdViewClosed:)]) {
        [self.delegate mercury_nativeExpressAdViewClosed:self];
    }
}

// MARK: ======================= MercuryAdViewDelegate =======================
/// 广告内容被点击
- (void)mercuryAdViewDidClickWithImp:(MercuryImp *)imp {
    if ([self.delegate respondsToSelector:@selector(mercury_nativeExpressAdViewClicked:)]) {
        [self.delegate mercury_nativeExpressAdViewClicked:self];
    }
}

/// 广告内容被曝光
- (void)mercuryAdViewDidExpressWithImp:(MercuryImp *)imp {
    if ([self.delegate respondsToSelector:@selector(mercury_nativeExpressAdViewExposure:)]) {
        [self.delegate mercury_nativeExpressAdViewExposure:self];
    }
}

/// 广告资源尺寸被获取成功
- (void)mercuryAdViewAdSourceDidRecevedWithImp:(MercuryImp *)imp size:(CGSize)impSize {
    [self layoutSubviewsWithImpSize:impSize];
    if (CGSizeEqualToSize(impSize, CGSizeZero)) {
        if ([self.delegate respondsToSelector:@selector(mercury_nativeExpressAdViewRenderFail:)]) {
            [self.delegate mercury_nativeExpressAdViewRenderFail:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(mercury_nativeExpressAdViewRenderSuccess:)]) {
            [self.delegate mercury_nativeExpressAdViewRenderSuccess:self];
        }
    }
}

/// 播放状态变更
- (void)mercuryAdViewVideoStatusChangeWithImp:(MercuryImp *)imp status:(MercuryMediaPlayerStatus)status {
//    NSLog(@"%@", kMercuryMediaPlayerStatusParseToString(status));
}

// 时间变更
- (void)mercuryAdViewVideoTimeCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime {
    if (ceil(currentTime) == 1) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideoStart resultBlock:nil];
    } else if (ceil(currentTime) == ceil(totalTime/2.0)) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideoMid resultBlock:nil];
    } else if (ceil(currentTime) >= ceil(totalTime)) {
        [self.adView.curImp reportWithEventType:MercuryBaseAdRepoTKEventTypeVideoEnd resultBlock:nil];
    }
}

// MARK: ======================= UIGestureRecognizerDelegate =======================
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    if([touch.view isDescendantOfView:self.closeBtn]) { // 响应关闭
        return NO;
    } else if ([touch.view isDescendantOfView:self.adView] &&
               self.adView.curImp.isVideoType &&
               self.adView.handle.userControlEnable) {
        // 如果是可操作的视频视图
        return NO;
    }
    return YES;
}

// MARK: ======================= template_id =======================
/// 上图下文
- (void)setlayout_00WithImpSize:(CGSize)impSize {
    CGFloat real_w = _size.width-2*kNativeExpressMarg;
    CGFloat real_h = impSize.height*(real_w/impSize.width);
    // 广告内容
    [self addSubview:_adView];
    [_adView.topAnchor constraintEqualToAnchor:self.topAnchor constant:kNativeExpressMarg].active = YES;
    [_adView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:kNativeExpressMarg].active = YES;
    [_adView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kNativeExpressMarg].active = YES;
    if (!_adViewAnchorH) {
        _adViewAnchorH = [_adView.heightAnchor constraintEqualToConstant:real_h];
    } else {
        _adViewAnchorH.constant = real_h;
    }
    _adViewAnchorH.active = YES;
    
    // title
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:titleLbl];
    titleLbl.text = _adView.curImp.title;
    titleLbl.font = [UIFont systemFontOfSize:16*kNativeExpressFontScale(_size.width)];
    titleLbl.numberOfLines = 2;
    titleLbl.textColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:1.00];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLbl.topAnchor constraintEqualToAnchor:_adView.bottomAnchor constant:kNativeExpressMarg].active = YES;
    [titleLbl.leftAnchor constraintEqualToAnchor:_adView.leftAnchor constant:0].active = YES;
    [titleLbl.rightAnchor constraintEqualToAnchor:_adView.rightAnchor constant:0].active = YES;
    
    // subtitle
    UILabel *subtitleLbl;
    if (_adView.curImp.desc.length > 0) {
        subtitleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:subtitleLbl];
        subtitleLbl.text = _adView.curImp.desc;
        subtitleLbl.font = [UIFont systemFontOfSize:14*kNativeExpressFontScale(_size.width)];
        subtitleLbl.textColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.36 alpha:1.00];
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
        subtitleLbl.numberOfLines = 2;
        [subtitleLbl.topAnchor constraintEqualToAnchor:titleLbl.bottomAnchor constant:kNativeExpressPadd].active = YES;
        [subtitleLbl.leftAnchor constraintEqualToAnchor:_adView.leftAnchor constant:0].active = YES;
    }
    // 关闭
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:kMercuryImageNamed(@"_mercury_sdk3_0_close") forState:UIControlStateNormal];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:closeBtn];
    [closeBtn.rightAnchor constraintEqualToAnchor:_adView.rightAnchor constant:0].active = YES;
    [closeBtn.widthAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.heightAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.centerYAnchor constraintEqualToAnchor:(subtitleLbl?subtitleLbl:titleLbl).centerYAnchor].active = YES;
    [closeBtn addTarget:self action:@selector(viewClick) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn = closeBtn;
    
    if (subtitleLbl) {
        [subtitleLbl.rightAnchor constraintEqualToAnchor:closeBtn.leftAnchor constant:-kNativeExpressPadd].active = YES;
    }
    
    [self layoutIfNeeded];
    _isReady = YES;
    if (_adSizeMode == MercuryNativeExpressAdSizeModeAutoSize) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(closeBtn.frame)+kNativeExpressMarg);
    }
}

/// 上文下图
- (void)setlayout_01WithImpSize:(CGSize)impSize {
    CGFloat real_w = _size.width-2*kNativeExpressMarg;
    CGFloat real_h = impSize.height*(real_w/impSize.width);
    
    // title
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:titleLbl];
    titleLbl.text = _adView.curImp.title;
    titleLbl.font = [UIFont systemFontOfSize:16*kNativeExpressFontScale(_size.width)];
    titleLbl.numberOfLines = 2;
    titleLbl.textColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:1.00];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLbl.topAnchor constraintEqualToAnchor:self.topAnchor constant:kNativeExpressMarg].active = YES;
    [titleLbl.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:kNativeExpressMarg].active = YES;
    [titleLbl.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kNativeExpressMarg].active = YES;
    
    UIView *lastV = titleLbl;
    // subtitle
    
    if (_adView.curImp.desc.length > 0) {
        UILabel *subtitleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:subtitleLbl];
        subtitleLbl.text = _adView.curImp.desc;
        subtitleLbl.font = [UIFont systemFontOfSize:14*kNativeExpressFontScale(_size.width)];
        subtitleLbl.numberOfLines = 2;
        subtitleLbl.textColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.36 alpha:1.00];
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
        [subtitleLbl.topAnchor constraintEqualToAnchor:titleLbl.bottomAnchor constant:kNativeExpressPadd].active = YES;
        [subtitleLbl.leftAnchor constraintEqualToAnchor:titleLbl.leftAnchor constant:0].active = YES;
        [subtitleLbl.rightAnchor constraintEqualToAnchor:titleLbl.rightAnchor constant:0].active = YES;
        lastV = subtitleLbl;
    }
    
    // 广告内容
    [self addSubview:_adView];
    [_adView.topAnchor constraintEqualToAnchor:lastV.bottomAnchor constant:kNativeExpressMarg].active = YES;
    [_adView.leftAnchor constraintEqualToAnchor:lastV.leftAnchor constant:0].active = YES;
    [_adView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kNativeExpressMarg].active = YES;
    if (!_adViewAnchorH) {
        _adViewAnchorH = [_adView.heightAnchor constraintEqualToConstant:real_h];
    } else {
        _adViewAnchorH.constant = real_h;
    }
    _adViewAnchorH.active = YES;
    
    // 关闭
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:kMercuryImageNamed(@"_mercury_sdk3_0_close") forState:UIControlStateNormal];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:closeBtn];
    [closeBtn.rightAnchor constraintEqualToAnchor:_adView.rightAnchor constant:0].active = YES;
    [closeBtn.widthAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.heightAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.topAnchor constraintEqualToAnchor:_adView.bottomAnchor constant:kNativeExpressPadd].active = YES;
    [closeBtn addTarget:self action:@selector(viewClick) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn = closeBtn;
    
    [self layoutIfNeeded];
    _isReady = YES;
    if (_adSizeMode == MercuryNativeExpressAdSizeModeAutoSize) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(closeBtn.frame)+kNativeExpressMarg);
    }
}

/// 左图右文
- (void)setlayout_02WithImpSize:(CGSize)impSize {
    CGFloat adWMulti = 0.4;
    CGFloat real_w = _size.width-2*kNativeExpressMarg;//[UIScreen mainScreen].bounds.size.width-12;
    CGFloat real_h = impSize.height*(real_w/impSize.width);
    // 广告内容
    [self addSubview:_adView];
    [_adView.topAnchor constraintEqualToAnchor:self.topAnchor constant:kNativeExpressMarg].active = YES;
    [_adView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:kNativeExpressMarg].active = YES;
    [_adView.widthAnchor constraintEqualToConstant:real_w*adWMulti].active = YES;
    if (!_adViewAnchorH) {
        _adViewAnchorH = [_adView.heightAnchor constraintEqualToConstant:real_h*adWMulti];
    } else {
        _adViewAnchorH.constant = real_h*adWMulti;
    }
    _adViewAnchorH.active = YES;
    
    // title
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:titleLbl];
    titleLbl.text = _adView.curImp.title;
    titleLbl.font = [UIFont systemFontOfSize:16*kNativeExpressFontScale(_size.width)];
    titleLbl.textColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:1.00];
    titleLbl.numberOfLines = 2;
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLbl.topAnchor constraintEqualToAnchor:_adView.topAnchor constant:0].active = YES;
    [titleLbl.leftAnchor constraintEqualToAnchor:_adView.rightAnchor constant:kNativeExpressMarg].active = YES;
    [titleLbl.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kNativeExpressMarg].active = YES;
    // subtitle
    UILabel *subtitleLbl;
    if (_adView.curImp.desc.length > 0) {
        subtitleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:subtitleLbl];
        subtitleLbl.text = _adView.curImp.desc;
        subtitleLbl.font = [UIFont systemFontOfSize:14*kNativeExpressFontScale(_size.width)];
        subtitleLbl.numberOfLines = 2;
        subtitleLbl.textColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.36 alpha:1.00];
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
        [subtitleLbl.topAnchor constraintEqualToAnchor:titleLbl.bottomAnchor constant:kNativeExpressPadd].active = YES;
        [subtitleLbl.leftAnchor constraintEqualToAnchor:titleLbl.leftAnchor constant:0].active = YES;
    }
    // 关闭
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:kMercuryImageNamed(@"_mercury_sdk3_0_close") forState:UIControlStateNormal];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:closeBtn];
    [closeBtn.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kNativeExpressMarg].active = YES;
    [closeBtn.widthAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.heightAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.bottomAnchor constraintEqualToAnchor:_adView.bottomAnchor].active = YES;
    [closeBtn addTarget:self action:@selector(viewClick) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn = closeBtn;
    
    if (subtitleLbl) {
        [subtitleLbl.rightAnchor constraintEqualToAnchor:closeBtn.leftAnchor constant:-kNativeExpressPadd].active = YES;
    }
    [self layoutIfNeeded];
    // 重新计算广告高度
    if (subtitleLbl) {
        if (_adViewAnchorH.constant < (CGRectGetMaxY(subtitleLbl.frame)-CGRectGetMinY(titleLbl.frame))) {
            _adViewAnchorH.constant = (CGRectGetMaxY(subtitleLbl.frame)-CGRectGetMinY(titleLbl.frame));
        }
    }
    [self layoutIfNeeded];
    _isReady = YES;
    if (_adSizeMode == MercuryNativeExpressAdSizeModeAutoSize) {
        if (subtitleLbl) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 2*kNativeExpressMarg + (CGRectGetMaxY(subtitleLbl.frame)-CGRectGetMinY(titleLbl.frame)));
        } else {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, kNativeExpressMarg + CGRectGetMaxY(_adView.frame));
        }
    }
}

/// 左文右图
- (void)setlayout_03WithImpSize:(CGSize)impSize {
    CGFloat adWMulti = 0.4;
    CGFloat real_w = _size.width-2*kNativeExpressMarg;
    CGFloat real_h = impSize.height*(real_w/impSize.width);
    // 广告内容
    [self addSubview:_adView];
    [_adView.topAnchor constraintEqualToAnchor:self.topAnchor constant:kNativeExpressMarg].active = YES;
    [_adView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kNativeExpressMarg].active = YES;
    [_adView.widthAnchor constraintEqualToConstant:real_w*adWMulti].active = YES;
    if (!_adViewAnchorH) {
        _adViewAnchorH = [_adView.heightAnchor constraintEqualToConstant:real_h*adWMulti];
    } else {
        _adViewAnchorH.constant = real_h*adWMulti;
    }
    _adViewAnchorH.active = YES;
    
    // title
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:titleLbl];
    titleLbl.text = _adView.curImp.title;
    titleLbl.font = [UIFont systemFontOfSize:16*kNativeExpressFontScale(_size.width)];
    titleLbl.textColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:1.00];
    titleLbl.numberOfLines = 2;
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLbl.topAnchor constraintEqualToAnchor:_adView.topAnchor constant:0].active = YES;
    [titleLbl.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:kNativeExpressMarg].active = YES;
    [titleLbl.rightAnchor constraintEqualToAnchor:_adView.leftAnchor constant:-kNativeExpressMarg].active = YES;
    // subtitle
    
    UILabel *subtitleLbl;
    if (_adView.curImp.desc.length > 0) {
        subtitleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:subtitleLbl];
        subtitleLbl.text = _adView.curImp.desc;
        subtitleLbl.font = [UIFont systemFontOfSize:14*kNativeExpressFontScale(_size.width)];
        subtitleLbl.numberOfLines = 2;
        subtitleLbl.textColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.36 alpha:1.00];
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
        [subtitleLbl.topAnchor constraintEqualToAnchor:titleLbl.bottomAnchor constant:kNativeExpressPadd].active = YES;
        [subtitleLbl.leftAnchor constraintEqualToAnchor:titleLbl.leftAnchor constant:0].active = YES;
    }
    // 关闭
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:kMercuryImageNamed(@"_mercury_sdk3_0_close") forState:UIControlStateNormal];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:closeBtn];
    [closeBtn.rightAnchor constraintEqualToAnchor:_adView.leftAnchor constant:-kNativeExpressPadd].active = YES;
    [closeBtn.widthAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.heightAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.bottomAnchor constraintEqualToAnchor:_adView.bottomAnchor constant:0].active = YES;
    [closeBtn addTarget:self action:@selector(viewClick) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn = closeBtn;
    
    if (subtitleLbl) {
        [subtitleLbl.rightAnchor constraintEqualToAnchor:closeBtn.leftAnchor constant:-kNativeExpressPadd].active = YES;
    }
    
    [self layoutIfNeeded];
    // 重新计算广告高度
    if (subtitleLbl) {
        if (_adViewAnchorH.constant < (CGRectGetMaxY(subtitleLbl.frame)-CGRectGetMinY(titleLbl.frame))) {
            _adViewAnchorH.constant = (CGRectGetMaxY(subtitleLbl.frame)-CGRectGetMinY(titleLbl.frame));
        }
    }
    [self layoutIfNeeded];
    _isReady = YES;
    if (_adSizeMode == MercuryNativeExpressAdSizeModeAutoSize) {
        if (subtitleLbl) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 2*kNativeExpressMarg + (CGRectGetMaxY(subtitleLbl.frame)-CGRectGetMinY(titleLbl.frame)));
        } else {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, kNativeExpressMarg + CGRectGetMaxY(_adView.frame));
        }
    }
}

/// 双图单文
- (void)setlayout_04WithImpSize:(CGSize)impSize {
    CGFloat real_w = _size.width-2*kNativeExpressMarg;
    CGFloat real_h = impSize.height*(real_w/impSize.width);
    
    // icon
    UIImageView *iconImgV = [[UIImageView alloc] init];
    [self addSubview:iconImgV];
    iconImgV.translatesAutoresizingMaskIntoConstraints = NO;
    [iconImgV sd_setImageWithURL:[NSURL URLWithString:_adView.curImp.logo] placeholderImage:nil];
    [iconImgV.topAnchor constraintEqualToAnchor:self.topAnchor constant:kNativeExpressMarg].active = YES;
    [iconImgV.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:kNativeExpressMarg].active = YES;
    [iconImgV.heightAnchor constraintEqualToConstant:48].active = YES;
    [iconImgV.widthAnchor constraintEqualToConstant:48].active = YES;
    
    // title
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:titleLbl];
    titleLbl.text = _adView.curImp.title;
    titleLbl.font = [UIFont systemFontOfSize:16*kNativeExpressFontScale(_size.width)];
    titleLbl.numberOfLines = 2;
    titleLbl.textColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:1.00];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLbl.centerYAnchor constraintEqualToAnchor:iconImgV.centerYAnchor constant:0].active = YES;
    [titleLbl.leftAnchor constraintEqualToAnchor:iconImgV.rightAnchor constant:kNativeExpressMarg].active = YES;
    [titleLbl.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kNativeExpressMarg].active = YES;
    
    // subtitle
    UILabel *subtitleLbl;
    if (_adView.curImp.desc.length > 0) {
        subtitleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:subtitleLbl];
        subtitleLbl.text = _adView.curImp.desc;
        subtitleLbl.font = [UIFont systemFontOfSize:14*kNativeExpressFontScale(_size.width)];
        subtitleLbl.numberOfLines = 2;
        subtitleLbl.textColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.36 alpha:1.00];
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
        [subtitleLbl.topAnchor constraintEqualToAnchor:iconImgV.bottomAnchor constant:kNativeExpressPadd].active = YES;
        [subtitleLbl.leftAnchor constraintEqualToAnchor:iconImgV.leftAnchor constant:0].active = YES;
        [subtitleLbl.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kNativeExpressMarg].active = YES;
    }
    
    // 广告内容
    [self addSubview:_adView];
    [_adView.topAnchor constraintEqualToAnchor:(subtitleLbl?subtitleLbl:titleLbl).bottomAnchor constant:kNativeExpressMarg].active = YES;
    [_adView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:kNativeExpressMarg].active = YES;
    [_adView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kNativeExpressMarg].active = YES;
    if (!_adViewAnchorH) {
        _adViewAnchorH = [_adView.heightAnchor constraintEqualToConstant:real_h];
    } else {
        _adViewAnchorH.constant = real_h;
    }
    _adViewAnchorH.active = YES;
    
    // 关闭
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:kMercuryImageNamed(@"_mercury_sdk3_0_close") forState:UIControlStateNormal];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:closeBtn];
    [closeBtn.rightAnchor constraintEqualToAnchor:_adView.rightAnchor constant:0].active = YES;
    [closeBtn.widthAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.heightAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.topAnchor constraintEqualToAnchor:_adView.bottomAnchor constant:kNativeExpressPadd].active = YES;
    [closeBtn addTarget:self action:@selector(viewClick) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn = closeBtn;
    
    [self layoutIfNeeded];
    _isReady = YES;
    if (_adSizeMode == MercuryNativeExpressAdSizeModeAutoSize) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(closeBtn.frame)+kNativeExpressMarg);
    }
}

// MARK: ======================= get =======================
- (MercuryAdViewVideoHandle *)handle {
    return _adView.handle;
}

@end
