//
//  NSObject+Mercury.m
//  MercurySDK
//
//  Created by CherryKing on 2020/3/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "NSObject+Mercury.h"
#import <objc/runtime.h>

@implementation NSObject (Mercury)
- (NSDictionary *)mercury_getAllProperties {
   NSMutableDictionary *props = [NSMutableDictionary dictionary];
   unsigned int outCount, i;
   objc_property_t *properties = class_copyPropertyList([self class], &outCount);
   for (i = 0; i<outCount; i++) {
       objc_property_t property = properties[i];
       const char* char_f =property_getName(property);
       NSString *propertyName = [NSString stringWithUTF8String:char_f];
       id propertyValue = [self valueForKey:(NSString *)propertyName];
       if (propertyValue) [props setObject:propertyValue forKey:propertyName];

    }
   free(properties);
   return props;
}
@end
