//
//  BY_HCDataUnitQueue.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCDataUnitQueue.h"
#import "BY_HCLog.h"

@interface BY_HCDataUnitQueue ()

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSMutableArray<BY_HCDataUnit *> *unitArray;

@end

@implementation BY_HCDataUnitQueue

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        self.path = path;
        NSMutableArray *unitArray = nil;
        @try {
            unitArray = [NSKeyedUnarchiver unarchiveObjectWithFile:self.path];
        } @catch (NSException *exception) {
            BY_HCLogDataUnitQueue(@"%p, Init exception\nname : %@\breason : %@\nuserInfo : %@", self, exception.name, exception.reason, exception.userInfo);
        }
        self.unitArray = [NSMutableArray array];
        for (BY_HCDataUnit *obj in unitArray) {
            if (obj.error) {
                [obj deleteFiles];
            } else {
                [self.unitArray addObject:obj];
            }
        }
    }
    return self;
}

- (NSArray<BY_HCDataUnit *> *)allUnits
{
    if (self.unitArray.count <= 0) {
        return nil;
    }
    return [self.unitArray copy];
}

- (BY_HCDataUnit *)unitWithKey:(NSString *)key
{
    if (key.length <= 0) {
        return nil;
    }
    BY_HCDataUnit *unit = nil;
    for (BY_HCDataUnit *obj in self.unitArray) {
        if ([obj.key isEqualToString:key]) {
            unit = obj;
            break;
        }
    }
    return unit;
}

- (void)putUnit:(BY_HCDataUnit *)unit
{
    if (!unit) {
        return;
    }
    if (![self.unitArray containsObject:unit]) {
        [self.unitArray addObject:unit];
    }
}

- (void)popUnit:(BY_HCDataUnit *)unit
{
    if (!unit) {
        return;
    }
    if ([self.unitArray containsObject:unit]) {
        [self.unitArray removeObject:unit];
    }
}

- (void)archive
{
    BY_HCLogDataUnitQueue(@"%p, Archive - Begin, %ld", self, (long)self.unitArray.count);
    [NSKeyedArchiver archiveRootObject:self.unitArray toFile:self.path];
    BY_HCLogDataUnitQueue(@"%p, Archive - End  , %ld", self, (long)self.unitArray.count);
}

@end
