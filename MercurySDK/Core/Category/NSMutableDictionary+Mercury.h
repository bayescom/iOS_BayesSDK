//
//  NSMutableDictionary+Mercury.h
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (Mercury)

- (void)mercury_safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (void)mercury_safeRemoveObjectForKey:(id)aKey;
- (id)mercury_objectForKeyNotNil:(id)aKey;

@end

NS_ASSUME_NONNULL_END
