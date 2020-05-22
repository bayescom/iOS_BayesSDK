//
//  NSDictionary+Mercury.h
//  MercurySDK
//
//  Created by CherryKing on 2019/11/4.
//  Copyright © 2019 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Mercury)

+ (instancetype)mercury_safeDictionaryWithObject:(id)object forKey:(id)key;
- (instancetype)mercury_safeInitWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys;
- (id)mercury_objectForKeyNotNil:(id)aKey;

@end

NS_ASSUME_NONNULL_END
