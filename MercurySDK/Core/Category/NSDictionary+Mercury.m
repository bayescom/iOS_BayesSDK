//
//  NSDictionary+Mercury.m
//  MercurySDK
//
//  Created by CherryKing on 2019/11/4.
//  Copyright © 2019 Mercury. All rights reserved.
//

#import "NSDictionary+Mercury.h"
#import "MercuryExceptionCollector.h"
#import <objc/runtime.h>

@implementation NSDictionary (Mercury)

- (instancetype)mercury_safeInitWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys {
    id dictionary = nil;
    @try {
        dictionary = [self initWithObjects:objects forKeys:keys];
    } @catch (NSException *exception) {
        if (objects && keys) {
            NSInteger count            = objects.count > keys.count ? keys.count : objects.count;
            NSMutableArray *newObjects = [NSMutableArray arrayWithCapacity:count];
            NSMutableArray *newkeys    = [NSMutableArray arrayWithCapacity:count];
            for (NSInteger i = 0; i < count; i++) {
                if (objects[i] && keys[i]) {
                    newObjects[i] = objects[i];
                    newkeys[i]    = keys[i];
                }
            }
            dictionary = [self mercury_safeInitWithObjects:newObjects forKeys:newkeys];
        }
        // 收集错误信息
        mercury_handleErrorWithException(exception);
    } @finally {
        return dictionary;
    }
}

+ (instancetype)mercury_safeDictionaryWithObject:(id)object forKey:(id)key {
    id dictionary = nil;
    @try {
        dictionary = [self dictionaryWithObject:object forKey:key];
    } @catch (NSException *exception) {
        // 收集错误信息
        mercury_handleErrorWithException(exception);
    } @finally {
        return dictionary;
    }
}

- (id)mercury_objectForKeyNotNil:(id)aKey {
    id obj = nil;
    @try {
        obj = [self objectForKey:aKey];
    } @catch (NSException *exception) {
        // 收集错误信息
        mercury_handleErrorWithException(exception);
        obj = @"";
    } @finally {
        return obj; // 返回空字符串
    }
}

@end


@implementation NSDictionary (Log)

/// old
- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [strM appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    [strM appendString:@"}\n"];
    return strM;
}

/// new
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [strM appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    [strM appendString:@"}\n"];
    return strM;
}

@end
