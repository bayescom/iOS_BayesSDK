//
//  NSObject+Mercury.h
//  MercurySDK
//
//  Created by CherryKing on 2020/3/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Mercury)
/// 获取对象的属性名：属性值 
- (NSDictionary *)mercury_getAllProperties;

@end

NS_ASSUME_NONNULL_END
