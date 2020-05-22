//
//  MercuryPreloadMediaInfo.m
//  MercurySDK
//
//  Created by CherryKing on 2020/2/27.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "MercuryPreloadMediaInfo.h"

#define λ(decl, expr) (^(decl) { return (expr); })

//static id NSNullify(id _Nullable x) {
//    return (x == nil || x == NSNull.null) ? NSNull.null : x;
//}

NS_ASSUME_NONNULL_BEGIN

@interface MercuryPreloadMediaInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface MercuryPreloadMediaInfoItem (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

@end

static id map(id collection, id (^f)(id value)) {
    id result = nil;
    if ([collection isKindOfClass:NSArray.class]) {
        result = [NSMutableArray arrayWithCapacity:[collection count]];
        for (id x in collection) [result addObject:f(x)];
    } else if ([collection isKindOfClass:NSDictionary.class]) {
        result = [NSMutableDictionary dictionaryWithCapacity:[collection count]];
        for (id key in collection) [result setObject:f([collection objectForKey:key]) forKey:key];
    }
    return result;
}

#pragma mark - JSON serialization

MercuryPreloadMediaInfo *_Nullable MercuryPreloadMediaInfoFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [MercuryPreloadMediaInfo fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

MercuryPreloadMediaInfo *_Nullable MercuryPreloadMediaInfoFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    return MercuryPreloadMediaInfoFromData([json dataUsingEncoding:encoding], error);
}

NSData *_Nullable MercuryPreloadMediaInfoToData(MercuryPreloadMediaInfo *preloadMediaInfo, NSError **error)
{
    @try {
        id json = [preloadMediaInfo JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable MercuryPreloadMediaInfoToJSON(MercuryPreloadMediaInfo *preloadMediaInfo, NSStringEncoding encoding, NSError **error)
{
    NSData *data = MercuryPreloadMediaInfoToData(preloadMediaInfo, error);
    return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
}

@implementation MercuryPreloadMediaInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"appid": @"appid",
        @"code": @"code",
        @"urls": @"urls",
    };
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    return MercuryPreloadMediaInfoFromData(data, error);
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    return MercuryPreloadMediaInfoFromJSON(json, encoding, error);
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[MercuryPreloadMediaInfo alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _urls = map(_urls, λ(id x, [MercuryPreloadMediaInfoItem fromJSONDictionary:x]));
    }
    return self;
}

- (NSDictionary *)JSONDictionary
{
    id dict = [[self dictionaryWithValuesForKeys:MercuryPreloadMediaInfo.properties.allValues] mutableCopy];

    [dict addEntriesFromDictionary:@{
        @"urls": map(_urls, λ(id x, [x JSONDictionary])),
    }];

    return dict;
}

- (NSData *_Nullable)toData:(NSError *_Nullable *)error
{
    return MercuryPreloadMediaInfoToData(self, error);
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    return MercuryPreloadMediaInfoToJSON(self, encoding, error);
}
@end

@implementation MercuryPreloadMediaInfoItem
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"url": @"url",
        @"file_type": @"fileType",
        @"start_time": @"startTime",
        @"end_time": @"endTime",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[MercuryPreloadMediaInfoItem alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    id resolved = MercuryPreloadMediaInfoItem.properties[key];
    if (resolved) [super setValue:value forKey:resolved];
}

- (NSDictionary *)JSONDictionary
{
    id dict = [[self dictionaryWithValuesForKeys:MercuryPreloadMediaInfoItem.properties.allValues] mutableCopy];

    for (id jsonName in MercuryPreloadMediaInfoItem.properties) {
        id propertyName = MercuryPreloadMediaInfoItem.properties[jsonName];
        if (![jsonName isEqualToString:propertyName]) {
            dict[jsonName] = dict[propertyName];
            [dict removeObjectForKey:propertyName];
        }
    }

    return dict;
}

- (BOOL)isVideo {
    BOOL isVFlag = NO;
    if ([self.fileType isEqualToString:@"mp4"]) {
        isVFlag = YES;
    }
    return isVFlag;
}

@end

NS_ASSUME_NONNULL_END
