//
//  MercuryFeedExpressViewController.m
//  Example
//
//  Created by CherryKing on 2019/12/20.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryFeedExpressViewController.h"
#import "FeedExpressViewController.h"

@interface MercuryFeedExpressViewController ()

@end

@implementation MercuryFeedExpressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"图片信息流", @"adspotId": @"10002698"},
        @{@"addesc": @"视频信息流", @"adspotId": @"10002710"},
    ];
    self.btn1Title = @"展示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    FeedExpressViewController *vc = [[FeedExpressViewController alloc] init];
    vc.count = 1;
    vc.adspotId = self.adspotId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
