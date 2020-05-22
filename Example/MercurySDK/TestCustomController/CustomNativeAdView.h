//
//  CustomNativeAdView.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/5/7.
//  Copyright © 2020 mercury. All rights reserved.
//

#import "MercuryNativeAdView.h"

@class MercuryImp;
NS_ASSUME_NONNULL_BEGIN

@interface CustomNativeAdView : UIView

- (instancetype)initAdWithImp:(MercuryImp *)imp size:(CGSize)size;

+ (CGFloat)cellHeightWithImp:(MercuryImp *)imp;

@end

NS_ASSUME_NONNULL_END
