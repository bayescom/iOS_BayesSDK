//
//  MercuryBaseAdSKVCDelegate.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/22.
//  Copyright © 2020 mercury. All rights reserved.
//

#ifndef MercuryBaseAdSKVCDelegate_h
#define MercuryBaseAdSKVCDelegate_h

@protocol MercuryBaseAdSKVCDelegate <NSObject>
@optional
/// 即将弹出全屏广告页
- (void)_mercury_skvcWillPresentFullScreenModal;

/// 已经弹出全屏广告页
- (void)_mercury_skvcDidPresentFullScreenModal;

/// 即将退出全屏广告页
- (void)_mercury_skvcWillDismissFullScreenModal;

/// 已经退出全屏广告页
- (void)_mercury_skvcDidDismissFullScreenModal;

@end

#endif /* MercuryBaseAdSKVCDelegate_h */
