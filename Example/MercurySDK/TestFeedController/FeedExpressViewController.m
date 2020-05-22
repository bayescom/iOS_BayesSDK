//
//  FeedExpressViewController.m
//  Example
//
//  Created by CherryKing on 2019/11/21.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "FeedExpressViewController.h"
#import "CellBuilder.h"
#import "BYExamCellModel.h"

#import "MercuryNativeExpressAd.h"

@interface FeedExpressViewController () <MercuryNativeExpressAdDelegete, MercuryNativeExpressAdViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) MercuryNativeExpressAd *ad;
// BYExamCellModelElement | BYNativeExpressAdView
@property (nonatomic, strong) NSMutableArray *dataArrM;

@end

@implementation FeedExpressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"信息流";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"splitnativeexpresscell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"nativeexpresscell"];
    [_tableView registerClass:[ExamTableViewCell class] forCellReuseIdentifier:@"ExamTableViewCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self loadBtnAction:nil];
}

- (void)loadBtnAction:(id)sender {
    _dataArrM = [NSMutableArray arrayWithArray:[CellBuilder dataFromJsonFile:@"cell01"]];
    _ad = [[MercuryNativeExpressAd alloc] initAdWithAdspotId:_adspotId];
    _ad.delegate = self;
    
    _ad.videoMuted = NO;
    _ad.videoPlayPolicy = MercuryVideoAutoPlayPolicyWIFI;
    
    _ad.renderSize = CGSizeMake(self.view.bounds.size.width, 100);
    [_ad loadAdWithCount:_count];
}

// MARK: ======================= MercuryNativeExpressAdDelegete =======================
/// 拉取数据成功
- (void)mercury_nativeExpressAdSuccessToLoad:(MercuryNativeExpressAd *)nativeExpressAd views:(NSArray<MercuryNativeExpressAdView *> *)views {
    NSLog(@"拉取数据成功 ");
    for (NSInteger i=0; i<views.count;i++) {
        views[i].adSizeMode = MercuryNativeExpressAdSizeModeAutoSize;
        if (i == 0) {
            [_dataArrM insertObject:views[i] atIndex:4];
        } else {
            [_dataArrM insertObject:views[i] atIndex:arc4random_uniform((int)views.count)];
        }
        views[i].delegate = self;
//        views[i].handle.userControlEnable = YES;
        [views[i] render];
    }
}

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoadWithError:(NSError *)error {
    NSLog(@"拉取原生模板广告失败 %@", error);
}

// MARK: ======================= MercuryNativeExpressAdViewDelegate =======================
/// 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
- (void)mercury_nativeExpressAdViewRenderSuccess:(MercuryNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"原生模板广告渲染成功, %@", nativeExpressAdView);
    if (nativeExpressAdView.isReady) {
        [self.tableView reloadData];
    }
}

/// 原生模板广告点击回调
- (void)mercury_nativeExpressAdViewClicked:(MercuryNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"原生模板广告点击回调, %@", nativeExpressAdView);
}

/// 原生模板广告被关闭
- (void)mercury_nativeExpressAdViewClosed:(MercuryNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"原生模板广告被关闭, %@", nativeExpressAdView);
    [self.tableView reloadData];
}

/// 原生模板广告曝光回调
- (void)mercury_nativeExpressAdViewExposure:(MercuryNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"原生模板广告曝光回调, %@", nativeExpressAdView);
}

/// 原生模板广告渲染失败
- (void)mercury_nativeExpressAdViewRenderFail:(MercuryNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"原生模板广告渲染失败, %@", nativeExpressAdView);
}

- (void)mercury_nativeExpressAdView:(MercuryNativeExpressAdView *)nativeExpressAdView playerStatusChanged:(MercuryMediaPlayerStatus)status {
//    NSLog(@"%lu | %@", status, nativeExpressAdView);
}

// MARK: ======================= UITableViewDelegate, UITableViewDataSource =======================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return _expressAdViews.count*2;
//    return 2;
    return _dataArrM.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_dataArrM[indexPath.row] isKindOfClass:[MercuryNativeExpressAdView class]]) {
        return ((MercuryNativeExpressAdView *)_dataArrM[indexPath.row]).bounds.size.height;
    } else if ([_dataArrM[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        return ((BYExamCellModelElement *)_dataArrM[indexPath.row]).cellh;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([_dataArrM[indexPath.row] isKindOfClass:[MercuryNativeExpressAdView class]]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"nativeexpresscell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIView *subView = (UIView *)[cell.contentView viewWithTag:1000];
        if ([subView superview]) {
            [subView removeFromSuperview];
        }
        MercuryNativeExpressAdView *view = _dataArrM[indexPath.row];
        view.tag = 1000;
        [cell.contentView addSubview:view];
        cell.accessibilityIdentifier = @"nativeTemp_ad";
    } else if ([_dataArrM[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ExamTableViewCell"];
        ((ExamTableViewCell *)cell).item = _dataArrM[indexPath.row];
        return cell;
    }
    return cell;
}

@end


