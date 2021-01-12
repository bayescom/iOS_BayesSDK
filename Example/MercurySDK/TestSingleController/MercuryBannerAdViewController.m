//
//  MercuryBannerAdViewController.m
//  Example
//
//  Created by CherryKing on 2019/11/8.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryBannerAdViewController.h"
#import "ViewBuilder.h"

#import <MercurySDK/MercurySDK.h>

@interface MercuryBannerAdViewController () <MercuryBannerAdViewDelegate>
@property (nonatomic, strong) MercuryBannerAdView *bannerView;

@property (nonatomic, strong) UILabel *lbl01;
@property (nonatomic, strong) UISwitch *switch01;
@property (nonatomic, strong) UILabel *lbl02;
@property (nonatomic, strong) UISwitch *switch02;
@property (nonatomic, strong) UITextField *updateTimeTxtf;
@property (nonatomic, strong) UIButton *updateTimeBtn;

@end

@implementation MercuryBannerAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"Banner", @"adspotId": @"10000558"},
        
//        @{@"addesc": @"横幅", @"adspotId": @"20000001"},
    ];
    self.btn1Title = @"加载并显示广告";
    self.btn2Title = @"移除广告";
    
    // custom view
    [self initCustomView];
}

- (void)initCustomView {
    [self.cusView addSubview:self.lbl01];
    [self.cusView addSubview:self.switch01];
    [self.cusView addSubview:self.lbl02];
    [self.cusView addSubview:self.switch02];
    [self.cusView addSubview:self.updateTimeBtn];
    [self.cusView addSubview:self.updateTimeTxtf];
    _lbl01.text = @"隐藏关闭按钮";
    _lbl02.text = @"广告切换动画";
    _lbl01.frame = CGRectMake(0, 0, 120, 40);
    _switch01.frame = CGRectMake(120, 0, 0, 0);
    _lbl02.frame = CGRectMake(0, 40, 120, 40);
    _switch02.frame = CGRectMake(120, 40, 0, 0);
    _updateTimeTxtf.frame = CGRectMake(0, 80, 160, 40);
    _updateTimeBtn.frame = CGRectMake(0, 120, 160, 40);
}

- (void)reloadTimeTxtFChange:(UITextField *)textField {
    self.bannerView.interval = [textField.text intValue];
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    [_bannerView removeFromSuperview];
    _bannerView = nil;
    
    _bannerView = [[MercuryBannerAdView alloc] initWithFrame:CGRectZero
                                               adspotId:self.adspotId
                                               delegate:self];
    _bannerView.controller = self;
    _bannerView.showCloseBtn = _switch01.on;
    _bannerView.animationOn = _switch02.on;
    _bannerView.interval = 30;//[_updateTimeTxtf.text intValue];
    _bannerView.delegate = self;
    
    CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*5/32.0);
    _bannerView.frame = rect;
    [self.adShowView addSubview:_bannerView];
    self.adShowView.hidden = NO;
    
    [self.bannerView loadAdAndShow];
}

- (void)loadAdBtn2Action {
    [_bannerView removeFromSuperview];
    _bannerView = nil;
}

// MARK: ======================= MercuryBannerAdViewDelegate =======================

/// 请求广告条数据成功后调用
- (void)mercury_bannerViewDidReceived:(MercuryBannerAdView *)banner {
    NSLog(@"请求广告条数据成功后调用 %s", __func__);
}

/// 请求广告条数据失败后调用
- (void)mercury_bannerViewFailToReceived:(MercuryBannerAdView *)banner error:(NSError *)error {
    NSLog(@"请求广告条数据失败后调用 %s", __func__);
}

/// banner条被用户关闭时调用
- (void)mercury_bannerViewWillClose:(MercuryBannerAdView *)banner {
    NSLog(@"banner条被用户关闭时调用 %s", __func__);
}

/// banner条曝光回调
- (void)mercury_bannerViewWillExposure:(MercuryBannerAdView *)banner {
    NSLog(@"banner条曝光回调 %s", __func__);
}

/// banner条点击回调
- (void)mercury_bannerViewClicked:(MercuryBannerAdView *)banner {
    NSLog(@"banner条点击回调 %s", __func__);
}


// MARK: ======================= action =======================
- (void)switchChange:(UISwitch *)sender {
    if (sender == _switch01) {
        _bannerView.showCloseBtn = !_switch01.on;
    } else if (sender == _switch02) {
        _bannerView.animationOn = _switch02.on;
    }
}

- (void)updateTimeChange:(UIButton *)sender {
    _bannerView.interval = [_updateTimeTxtf.text intValue];
}

// MARK: ======================= get =======================
- (UILabel *)lbl01 {
    if (!_lbl01) {
        _lbl01 = [ViewBuilder buildLbl01];
    }
    return _lbl01;
}

- (UILabel *)lbl02 {
    if (!_lbl02) {
        _lbl02 = [ViewBuilder buildLbl01];
    }
    return _lbl02;
}

- (UISwitch *)switch01 {
    if (!_switch01) {
        _switch01 = [[UISwitch alloc] init];
        [_switch01 addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switch01;
}

- (UISwitch *)switch02 {
    if (!_switch02) {
        _switch02 = [[UISwitch alloc] init];
        [_switch02 addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switch02;
}

- (UIButton *)updateTimeBtn {
    if (!_updateTimeBtn) {
        _updateTimeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_updateTimeBtn setTitle:@"修改更新时间" forState:UIControlStateNormal];
        [_updateTimeBtn addTarget:self action:@selector(updateTimeChange:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _updateTimeBtn;
}

- (UITextField *)updateTimeTxtf {
    if (!_updateTimeTxtf) {
        _updateTimeTxtf = [ViewBuilder buildTxt01];
    }
    return _updateTimeTxtf;
}

@end
