//
//  BY_HCDataUnitQueue.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCDataUnit.h"

@interface BY_HCDataUnitQueue : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

- (NSArray<BY_HCDataUnit *> *)allUnits;
- (BY_HCDataUnit *)unitWithKey:(NSString *)key;

- (void)putUnit:(BY_HCDataUnit *)unit;
- (void)popUnit:(BY_HCDataUnit *)unit;

- (void)archive;

@end
