//
//  TestCustomFeedViewController.m
//  Example
//
//  Created by CherryKing on 2019/12/25.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "TestCustomFeedViewController.h"
#import "CellBuilder.h"
#import "BYExamCellModel.h"
#import "TestCustomFeedTableViewCell.h"

#import "MercuryNativeAd.h"

@interface TestCustomFeedViewController () <MercuryNativeAdDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArrM;
@property (nonatomic, strong) MercuryNativeAd *nativeAd;

@end

@implementation TestCustomFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"自渲染";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[TestCustomFeedTableViewCell class] forCellReuseIdentifier:@"TestCustomFeedTableViewCell"];
    [_tableView registerClass:[ExamTableViewCell class] forCellReuseIdentifier:@"ExamTableViewCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    
    [self loadBtnAction:nil];
}

- (void)loadBtnAction:(id)sender {
    _dataArrM = [NSMutableArray arrayWithArray:[CellBuilder dataFromJsonFile:@"cell01"]];
    _nativeAd = [[MercuryNativeAd alloc] initAdWithAdspotId:_adspotId];
    _nativeAd.delegate = self;
    [_nativeAd loadAd];
}

// MARK: ======================= MercuryNativeAdDelegate =======================
- (void)mercury_nativeAdLoaded:(NSArray<MercuryImp *> * _Nullable)adImps error:(NSError * _Nullable)error {
    NSLog(@"%s : 广告数据拉取回调 | %@", __func__, error);
    if (adImps.count <= 0) {
        [_tableView reloadData];
        return;
    }
//    [_dataArrM insertObject:adImps.firstObject atIndex:1];
    [_dataArrM insertObject:adImps.firstObject atIndex:3];
    [_tableView reloadData];
}

// MARK: ======================= UITableViewDelegate, UITableViewDataSource =======================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArrM.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_dataArrM[indexPath.row] isKindOfClass:NSClassFromString(@"MercuryImp")]) {
        return [TestCustomFeedTableViewCell cellHeightWithImp:_dataArrM[indexPath.row]];
    } else if ([_dataArrM[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        return ((BYExamCellModelElement *)_dataArrM[indexPath.row]).cellh;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([_dataArrM[indexPath.row] isKindOfClass:NSClassFromString(@"MercuryImp")]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TestCustomFeedTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ((TestCustomFeedTableViewCell *)cell).imp = _dataArrM[indexPath.row];
//        ((TestCustomFeedTableViewCell *)cell).adView.delegate = self;
//        [((TestCustomFeedTableViewCell *)cell) registerNativeAd:_nativeAd dataObject:_dataArrM[indexPath.row]];
    } else if ([_dataArrM[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ExamTableViewCell"];
        ((ExamTableViewCell *)cell).item = _dataArrM[indexPath.row];
        return cell;
    }
    return cell;
}

@end
