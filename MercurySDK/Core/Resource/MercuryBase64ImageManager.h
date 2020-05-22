//
//  MercuryBase64ImageManager.h
//  MercurySDK
//
//  Created by CherryKing on 2020/3/5.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface MercuryBase64ImageManager : NSObject
// 只支持了 PNG 格式图片
+ (UIImage *)base64ImageWithNamed:(NSString *)imgNamed;

+ (NSString *)imageToBase64:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
