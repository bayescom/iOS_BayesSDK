//
//  MercuryInterstitialAdVC.m
//  Example
//
//  Created by CherryKing on 2019/11/15.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryInterstitialAdVC.h"
#import "MercuryAdModel.h"
#import "MercuryAdView.h"
#import "MercuryPriHeader.h"

@interface MercuryInterstitialAdVC () <MercuryAdViewDelegate>

@property (nonatomic, strong) MercuryAdView *adView;
@property (nonatomic, strong) MercuryAdModel *adModel;

/// 广告标签
@property (nonatomic, strong) UILabel *sourceLbl;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, assign) BOOL isClick;

@end

@implementation MercuryInterstitialAdVC

- (instancetype)initAdWithAdspotId:(NSString *)adspotId appId:(NSString *)appId mediaKey:(NSString *)mediaKey {
    if (self = [super init]) {
        @mer_weakify(self);
        [MercuryAdModel loadAdWithAdspotId:adspotId
                                     appId:appId
                                  mediaKey:mediaKey
                                fetchDelay:3
                               resultBlock:^(NSError * _Nonnull error, MercuryAdModel * _Nonnull adModel) {
            @mer_strongify(self);
            if (!error) {
                if (![adModel.imp.firstObject checkAdType:MercuryAdModelType05
                                                 creativeTypes:@[@(MercuryAdModelCreativeType04)]]) {
                    if ([self.delegate respondsToSelector:@selector(mercury_interstitialFailError:)]) {
                        [self.delegate mercury_interstitialFailError:[MercuryError errorWitherror:MercuryResultCode211].toNSError];
                    }
                    return;
                }
                self.adModel = adModel;
                if ([self.delegate respondsToSelector:@selector(mercury_interstitialSuccess)]) {
                    [self.delegate mercury_interstitialSuccess];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(mercury_interstitialFailError:)]) {
                    [self.delegate mercury_interstitialFailError:error];
                }
            }
        }];
    }
    return self;
}

- (void)showFromVC:(UIViewController *)vc {
//    if (_adView.renderSuccess) {
        [vc presentViewController:self animated:NO completion:nil];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:0.3];
    [self.view addSubview:_adView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isClick = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!_isClick &&
        [_delegate respondsToSelector:@selector(mercury_interstitialDidDismissScreen)]) {
        [_delegate mercury_interstitialDidDismissScreen];
        [_adView destory];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}
/** 支持的方向 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setSubviewsAutoLayoutWithImp:(MercuryImp *)imp size:(CGSize)impSize {
    if (CGSizeEqualToSize(impSize, _adView.bounds.size)) {
        return;
    }
    [self layoutSubviewsWithImpSize:impSize];
}

- (void)layoutSubviewsWithImpSize:(CGSize)impSize {
    CGFloat real_w = impSize.width>[UIScreen mainScreen].bounds.size.width?[UIScreen mainScreen].bounds.size.width*0.9:impSize.width;
    CGFloat real_h = impSize.height*(real_w/impSize.width);
    // 广告内容
    [self.view addSubview:_adView];
    if (_adView) {
        [_adView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [_adView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
        [_adView.widthAnchor constraintEqualToConstant:real_w].active = YES;
        [_adView.heightAnchor constraintEqualToConstant:real_h].active = YES;
    }
    
    // 关闭按钮
    [self.view addSubview:self.closeBtn];
    [_closeBtn.topAnchor constraintEqualToAnchor:_adView.topAnchor constant:4].active = YES;
    [_closeBtn.rightAnchor constraintEqualToAnchor:_adView.rightAnchor constant:-4].active = YES;
    [_closeBtn.heightAnchor constraintEqualToConstant:24.0].active = YES;
    [_closeBtn.widthAnchor constraintEqualToConstant:24.0].active = YES;
    
    // 广告标记
    [self.view addSubview:self.sourceLbl];
    _sourceLbl.text = _adView.curImp.adsource;
    [_sourceLbl.rightAnchor constraintEqualToAnchor:_adView.rightAnchor].active = YES;
    [_sourceLbl.bottomAnchor constraintEqualToAnchor:_adView.bottomAnchor].active = YES;
}

// MARK: ======================= Action =======================
- (void)dismissSelf:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
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

- (void)setAdModel:(MercuryAdModel *)adModel {
    _adModel = adModel;
    if (_adModel.imp.count <= 0) {
        return;
    }
    
    [_adView removeFromSuperview];
    [_sourceLbl removeFromSuperview];
    
    _adView = [[MercuryAdView alloc] initAdWithImp:adModel.imp.firstObject];
    _adView.delegate = self;
    [_adView renderWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width*0.8,
                                       [UIScreen mainScreen].bounds.size.width*0.8)];
}

// MARK: ======================= MercuryAdViewDelegate =======================
/// 广告内容被点击
- (void)mercuryAdViewDidClickWithImp:(MercuryImp *)imp {
    _isClick = YES;
    if ([self.delegate respondsToSelector:@selector(mercury_interstitialClicked)]) {
        [self.delegate mercury_interstitialClicked];
    }
}

/// 广告内容被曝光
- (void)mercuryAdViewDidExpressWithImp:(MercuryImp *)imp {
    if ([_delegate respondsToSelector:@selector(mercury_interstitialDidPresentScreen)]) {
        [_delegate mercury_interstitialDidPresentScreen];
    }
    if ([_delegate respondsToSelector:@selector(mercury_interstitialWillExposure)]) {
        [_delegate mercury_interstitialWillExposure];
    }
}

/// 广告资源尺寸被获取成功
- (void)mercuryAdViewAdSourceDidRecevedWithImp:(MercuryImp *)imp size:(CGSize)impSize {
    [self setSubviewsAutoLayoutWithImp:imp size:impSize];
}

@end
