//
//  NSMutableDictionary+Mercury.m
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "NSMutableDictionary+Mercury.h"
#import "MercuryExceptionCollector.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (Mercury)

- (void)mercury_safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    @try {
        [self setObject:anObject forKey:aKey];
    }
    @catch (NSException *exception) {
        // 收集错误信息
        mercury_handleErrorWithException(exception);
    }
    @finally {
        
    }
}

- (void)mercury_safeRemoveObjectForKey:(id)aKey {
    @try {
        [self removeObjectForKey:aKey];
    }
    @catch (NSException *exception) {
        // 收集错误信息
        mercury_handleErrorWithException(exception);
    }
    @finally {
        
    }
}

- (id)mercury_objectForKeyNotNil:(id)aKey {
    id obj = [self objectForKey:aKey];
    return obj?obj:@"";
}


@end

