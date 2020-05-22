//
//  TestCustomFeedTableViewCell.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/5/7.
//  Copyright © 2020 mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MercuryImp;
NS_ASSUME_NONNULL_BEGIN

@interface TestCustomFeedTableViewCell : UITableViewCell
@property (nonatomic, strong) MercuryImp *imp;

+ (CGFloat)cellHeightWithImp:(MercuryImp *)imp;

@end

NS_ASSUME_NONNULL_END
