//
//  CustomNativeAdView.m
//  MercurySDKExample
//
//  Created by CherryKing on 2020/5/7.
//  Copyright © 2020 mercury. All rights reserved.
//

#import "CustomNativeAdView.h"
#import "MercuryAdModel.h"
#import "MercuryNativeAdView.h"

static const CGFloat kNativeExpressMarg = 6;
static const CGFloat kNativeExpressPadd = 4;
static const CGFloat kNativeExpressCloseBWH = 18;

@interface CustomNativeAdView () <MercuryNativeAdViewDelegate>
@property (nonatomic, strong) MercuryNativeAdView *adView;

@property (nonatomic, strong, readonly) MercuryImp *imp;

@end

@implementation CustomNativeAdView

- (instancetype)initAdWithImp:(MercuryImp *)imp size:(CGSize)size {
    if (self = [super init]) {
        _adView = [[MercuryNativeAdView alloc] initAdWithImp:imp size:size];
        _adView.delegate = self;
        [self initSubviews];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)initSubviews {
    if (!self.imp) { return; }
    [self addSubview:_adView];
    [_adView render];
    
    // 修改默认配置
    _adView.handle.muted = YES;
    _adView.handle.hiddenSource = YES;
    _adView.handle.videoPlayPolicy = MercuryVideoAutoPlayPolicyWIFI;
    _adView.handle.userControlEnable = YES;
    _adView.handle.autoResumeEnable = YES;
    
    // title
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:titleLbl];
    titleLbl.text = self.imp.title;
    titleLbl.font = [UIFont systemFontOfSize:15];
    titleLbl.numberOfLines = 2;
    titleLbl.textColor = [UIColor colorWithRed:0.29 green:0.59 blue:1.00 alpha:1.00];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLbl.topAnchor constraintEqualToAnchor:_adView.bottomAnchor constant:kNativeExpressMarg].active = YES;
    [titleLbl.leftAnchor constraintEqualToAnchor:_adView.leftAnchor constant:0].active = YES;
    [titleLbl.rightAnchor constraintEqualToAnchor:_adView.rightAnchor constant:0].active = YES;

    // subtitle
    UILabel *subtitleLbl;
    if (self.imp.desc.length > 0) {
        subtitleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:subtitleLbl];
        subtitleLbl.text = self.imp.desc;
        subtitleLbl.font = [UIFont systemFontOfSize:13];
        subtitleLbl.textColor = [UIColor colorWithRed:0.27 green:0.79 blue:0.91 alpha:1.00];
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
        subtitleLbl.numberOfLines = 2;
        [subtitleLbl.topAnchor constraintEqualToAnchor:titleLbl.bottomAnchor constant:kNativeExpressPadd].active = YES;
        [subtitleLbl.leftAnchor constraintEqualToAnchor:_adView.leftAnchor constant:0].active = YES;
    }
    
    // source
    UILabel *sourceLbl;
    if (self.imp.adsource.length > 0) {
        sourceLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:sourceLbl];
        sourceLbl.text = self.imp.adsource;
        sourceLbl.font = [UIFont systemFontOfSize:10];
        sourceLbl.translatesAutoresizingMaskIntoConstraints = NO;
        sourceLbl.textAlignment = NSTextAlignmentCenter;
        [sourceLbl.topAnchor constraintEqualToAnchor:_adView.topAnchor constant:kNativeExpressPadd].active = YES;
        [sourceLbl.rightAnchor constraintEqualToAnchor:_adView.rightAnchor constant:-kNativeExpressPadd].active = YES;
        [sourceLbl.widthAnchor constraintEqualToConstant:30].active = YES;
        [sourceLbl.heightAnchor constraintEqualToConstant:15].active = YES;
        sourceLbl.layer.cornerRadius = 4;
        sourceLbl.layer.borderWidth = 1;
        sourceLbl.textColor = [UIColor yellowColor];
        sourceLbl.layer.borderColor = sourceLbl.textColor.CGColor;
    }
    
    // 关闭
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:closeBtn];
    [closeBtn.rightAnchor constraintEqualToAnchor:_adView.rightAnchor constant:0].active = YES;
    [closeBtn.widthAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.heightAnchor constraintEqualToConstant:kNativeExpressCloseBWH].active = YES;
    [closeBtn.centerYAnchor constraintEqualToAnchor:(subtitleLbl?subtitleLbl:titleLbl).centerYAnchor].active = YES;
    [closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
//    _closeBtn = closeBtn;

    if (subtitleLbl) {
        [subtitleLbl.rightAnchor constraintEqualToAnchor:closeBtn.leftAnchor constant:-kNativeExpressPadd].active = YES;
    }
    
    [_adView registAdClickViews:@[
        self,
    ]];
}

- (void)closeClick {
    NSLog(@"点击关闭");
}

+ (CGFloat)cellHeightWithImp:(MercuryImp *)imp {
    CGFloat height = 0;
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 2*kNativeExpressPadd;
    CGFloat imageRate = 640.0 / 320.0;
    CGFloat imageWidth = width;
    height = imageWidth / imageRate + 32;
//    imp.isVideoType
    return height;
}

// MARK: ======================= MercuryNativeAdViewDelegate =======================
/// 广告曝光回调
- (void)mercury_nativeAdViewWillExpose:(MercuryNativeAdView *)nativeAdView {
    NSLog(@"广告曝光回调");
}

/// 广告点击回调
- (void)mercury_nativeAdViewDidClick:(MercuryNativeAdView *)nativeAdView {
    NSLog(@"广告点击回调");
}

/// 广告渲染成功
- (void)mercury_nativeAdViewRenderSuccess:(MercuryNativeAdView *)nativeAdView adSize:(CGSize)adSize {
    NSLog(@"广告渲染成功");
}

/// 视频广告播放状态更改回调
- (void)mercury_nativeAdView:(MercuryNativeAdView *)nativeAdView playerStatusChanged:(MercuryMediaPlayerStatus)status {
    NSLog(@"视频广告播放状态更改回调");
}

// MARK: ======================= get =======================
- (MercuryImp *)imp {
    return _adView.imp;
}

@end
