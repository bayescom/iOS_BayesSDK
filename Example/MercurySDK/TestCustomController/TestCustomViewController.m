//
//  TestCustomViewController.m
//  Example
//
//  Created by CherryKing on 2019/12/25.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "TestCustomViewController.h"
#import "TestCustomFeedViewController.h"

@interface TestCustomViewController ()

@end

@implementation TestCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    50000005
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"图片信息流", @"adspotId": @"10002698"},
        @{@"addesc": @"视频信息流", @"adspotId": @"10002710"},
    ];
    self.btn1Title = @"展示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    TestCustomFeedViewController *vc = [[TestCustomFeedViewController alloc] init];
    vc.count = 1;
    vc.adspotId = self.adspotId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
