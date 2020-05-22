//
//  UIImage+Mercury.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/27.
//  Copyright © 2020 mercury. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Mercury)

/// 图片添加文字水印
- (UIImage *)addWatermarkWithText:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
