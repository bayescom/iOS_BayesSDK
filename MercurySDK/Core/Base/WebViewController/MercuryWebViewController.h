//
//  MercuryWebViewController.h
//  MercurySDK
//
//  Created by CherryKing on 2020/3/16.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryBaseAdSKVCDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryWebViewController : UIViewController

+ (UINavigationController *)navcWithUrl:(NSString *)url delegate:(id<MercuryBaseAdSKVCDelegate>)delegate;
- (instancetype)initWithUrl:(NSString *)url delegate:(id<MercuryBaseAdSKVCDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
