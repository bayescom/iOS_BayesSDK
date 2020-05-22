//
//  TestCustomFeedTableViewCell.m
//  MercurySDKExample
//
//  Created by CherryKing on 2020/5/7.
//  Copyright © 2020 mercury. All rights reserved.
//

#import "TestCustomFeedTableViewCell.h"
#import "CustomNativeAdView.h"

static const CGFloat kNativeExpressMarg = 6;
static const CGFloat kNativeExpressPadd = 4;
static const CGFloat kNativeExpressCloseBWH = 20;

@interface TestCustomFeedTableViewCell ()
@property (nonatomic, strong) CustomNativeAdView *adView;

@end

@implementation TestCustomFeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

// MARK: ======================= MercuryAdViewDelegate =======================

// MARK: ======================= set =======================
- (void)setImp:(MercuryImp *)imp {
    _imp = imp;
    
    _adView = [[CustomNativeAdView alloc] initAdWithImp:_imp size:CGSizeMake(self.bounds.size.width-2*kNativeExpressMarg, self.bounds.size.height)];
    [self.contentView addSubview:_adView];
    _adView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_adView.topAnchor constraintEqualToAnchor:self.topAnchor constant:kNativeExpressMarg].active = YES;
    [_adView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:kNativeExpressMarg].active = YES;
    [_adView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kNativeExpressMarg].active = YES;
    [_adView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-kNativeExpressMarg].active = YES;
}

// MARK: ======================= get =======================

+ (CGFloat)cellHeightWithImp:(MercuryImp *)imp {
    return [CustomNativeAdView cellHeightWithImp:imp];
}

@end
