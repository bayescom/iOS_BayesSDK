//
//  MercuryAdModel.m
//  AAA
//
//  Created by CherryKing on 2019/10/30.
//  Copyright © 2019 CherryKing. All rights reserved.
//
#import "MercuryAdModel.h"
#import "MercuryApiUtils.h"
//#import "MercuryPriHeader.h"
//#import "MercuryAppleAppInfoModel.h"

@class MercuryNativeAdDataModel;

#define λ(decl, expr) (^(decl) { return (expr); })

NS_ASSUME_NONNULL_BEGIN

/// 以字符串形式返回状态码
NSString * MercuryStringFromNMercuryBaseAdRepoTKEventType(MercuryBaseAdRepoTKEventType type) {
    switch (type) {
        case MercuryBaseAdRepoTKEventTypeShow:
            return @"MercuryBaseAdRepoTKEventTypeShow(曝光上报)";
        case MercuryBaseAdRepoTKEventTypeClick:
            return @"MercuryBaseAdRepoTKEventTypeClick(广告点击上报)";
        case MercuryBaseAdRepoTKEventTypeVideoStart:
            return @"MercuryBaseAdRepoTKEventTypeVideoStart(视频开始播放上报)";
        case MercuryBaseAdRepoTKEventTypeVideoMid:
            return @"MercuryBaseAdRepoTKEventTypeVideoMid(视频播放一半上报)";
        case MercuryBaseAdRepoTKEventTypeVideoEnd:
            return @"MercuryBaseAdRepoTKEventTypeVideoEnd(视频播放结束上报)";
        case MercuryBaseAdRepoTKEventTypeVideo1_4:
            return @"MercuryBaseAdRepoTKEventTypeVideo1_4(视频播放到1/4)";
        case MercuryBaseAdRepoTKEventTypeVideo3_4:
            return @"MercuryBaseAdRepoTKEventTypeVideo3_4(视频播放到3/4)";
        case MercuryBaseAdRepoTKEventTypeDeeplink:
            return @"MercuryBaseAdRepoTKEventTypeDeeplink(deeplink成功调起上报)";
            case MercuryBaseAdRepoTKEventTypeLink:
            return @"MercuryBaseAdRepoTKEventTypeLink(link成功调起上报)";
        case MercuryBaseAdRepoTKEventTypeTend:
            return @"MercuryBaseAdRepoTKEventTypeTend(倒计时结束上报)";
        case MercuryBaseAdRepoTKEventTypeSkip:
            return @"MercuryBaseAdRepoTKEventTypeSkip(点击跳过按钮上报)";
        default:
            return @"MercuryBaseAdRepoTKEventTypeUnknow(未知类型上报)";
    }
}

@interface MercuryAdModel () {
    MercuryError *_error;
}

@end

@interface MercuryAdModel (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface MercuryImp (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end


@interface MercuryImp ()
/// 弱引用一下adModel
@property (nonatomic, weak) MercuryAdModel *adModel;

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

MercuryAdModel *_Nullable MercuryAdModelFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [MercuryAdModel fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

MercuryAdModel *_Nullable MercuryAdModelFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    return MercuryAdModelFromData([json dataUsingEncoding:encoding], error);
}

NSData *_Nullable MercuryAdModelToData(MercuryAdModel *adModel, NSError **error)
{
    @try {
        id json = [adModel JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable MercuryAdModelToJSON(MercuryAdModel *adModel, NSStringEncoding encoding, NSError **error)
{
    NSData *data = MercuryAdModelToData(adModel, error);
    return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
}

@implementation MercuryAdModel
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"code": @"code",
        @"msg": @"msg",
        @"tcost": @"tcost",
        @"imp": @"imp",
    };
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    return MercuryAdModelFromData(data, error);
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    return MercuryAdModelFromJSON(json, encoding, error);
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[MercuryAdModel alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _imp = map(_imp, λ(id x, [MercuryImp fromJSONDictionary:x]));
        for (MercuryImp *a_imp in _imp) { a_imp.adModel = self; }
    }
    return self;
}

- (NSDictionary *)JSONDictionary
{
    id dict = [[self dictionaryWithValuesForKeys:MercuryAdModel.properties.allValues] mutableCopy];

    [dict addEntriesFromDictionary:@{
        @"imp": map(_imp, λ(id x, [x JSONDictionary])),
    }];

    return dict;
}

- (NSData *_Nullable)toData:(NSError *_Nullable *)error
{
    return MercuryAdModelToData(self, error);
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    return MercuryAdModelToJSON(self, encoding, error);
}

//- (NSArray <MercuryNativeAdDataModel *> *)toNativeAdDataModel {
//    NSMutableArray *arrM = [NSMutableArray array];
//    for (MercuryImp *imp in self.imp) {
//        if (imp.duration <= 0) {    // 如果广告没有曝光时间，默认 5 秒
//            imp.duration = 5;
//        }
//        [arrM addObject:[imp toNativeAdDataModel]];
//    }
//    return [arrM copy];
//}

@end

@implementation MercuryImp
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"downloadtk": @"downloadtk",
        @"starttk": @"starttk",
        @"impid": @"impid",
        @"clicktk": @"clicktk",
        @"action": @"action",
        @"win_price": @"winPrice",
        @"midtk": @"midtk",
        @"link": @"link",
        @"linktk": @"linktk",
        @"adtype": @"adtype",
        @"adsource": @"adsource",
        @"downloadedtk": @"downloadedtk",
        @"closetk": @"closetk",
        @"installedtk": @"installedtk",
        @"imptk": @"imptk",
        @"logo": @"logo",
        @"title": @"title",
        @"installtk": @"installtk",
        @"image": @"image",
        @"endtk": @"endtk",
        @"desc": @"desc",
        @"duration": @"duration",
        @"vurl": @"vurl",
        @"video_image": @"video_image",
        @"creative_type": @"creative_type",
        @"deeplink": @"deeplink",
        @"deeplinktk": @"deeplinktk",
        @"appleId": @"appleId",
        @"tendtk": @"tendtk",
        @"firsttk": @"firsttk",
        @"thirdtk": @"thirdtk",
        @"skiptk": @"skiptk",
        @"isExposured": @"isExposured",
        @"template_id" : @"template_id",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[MercuryImp alloc] initWithJSONDictionary:dict] : nil;
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
    id resolved = MercuryImp.properties[key];
    if (resolved) [super setValue:value forKey:resolved];
}

- (NSDictionary *)JSONDictionary
{
    id dict = [[self dictionaryWithValuesForKeys:MercuryImp.properties.allValues] mutableCopy];

    for (id jsonName in MercuryImp.properties) {
        id propertyName = MercuryImp.properties[jsonName];
        if (![jsonName isEqualToString:propertyName]) {
            dict[jsonName] = dict[propertyName];
            [dict removeObjectForKey:propertyName];
        }
    }

    return dict;
}

- (BOOL)isVideoType {
    // 开屏 | 视频
    if (_creative_type == MercuryAdModelCreativeType02) { return YES; }
    // 视频贴片 | 视频
    else if (_creative_type == MercuryAdModelCreativeType05) { return YES; }
    // 信息流 | 一视频
    else if (_creative_type == MercuryAdModelCreativeType09) { return YES; }
    // 激励视频 | 视频
    else if (_creative_type == MercuryAdModelCreativeType10) { return YES; }
    return NO;
}

- (BOOL)checkAdType:(MercuryAdModelType)adType creativeTypes:(NSArray<NSNumber *> *)creativeTypes {
    if (_adtype != adType) {
        return NO;
    }
    BOOL ct_okFlag = NO;
    for (NSNumber *creativeType_n in creativeTypes) {
        if (creativeType_n.unsignedIntegerValue == _creative_type) {
            ct_okFlag = YES;
        }
    }
    return ct_okFlag;
}

//- (void)loadAppInfoModelIfHasCompletionHandler:(void (^)(MercuryAppleAppInfoModel * _Nullable appInfoModel, NSError * _Nullable error))completionHandler {
//    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@", _appleId];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:
//            NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
//    [request setValue:@"application/json,text/json,text/javascript,text/html" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"ios" forHTTPHeaderField:@"client"];
//    [request setValue:[MercuryDeviceInfoUtil sharedInstance].ua forHTTPHeaderField:@"User-Agent"];
//    request.HTTPMethod = @"GET";
//    //use share session
//    NSURLSession *sharedSession = [NSURLSession sharedSession];
//
//    //use system dataTask
//    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
//                                                      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
//        NSError *jsonError;
//        MercuryAppleAppInfoModel *model = [MercuryAppleAppInfoModel fromData:data error:&jsonError];
//        if (completionHandler) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                completionHandler(model, error);
//            });
//        }
//    }];
//    [dataTask resume];
//}
//
//- (MercuryNativeAdDataModel *)toNativeAdDataModel {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//    @try {
//        return [MercuryNativeAdDataModel performSelector:@selector(modelWithImp:) withObject:self];
//    } @catch (NSException *exception) {
//        return nil;
//    } @finally {}
//
//#pragma clang diagnostic pop
//}

@end

@implementation MercuryAdModel (API)
/// 发起广告请求
/// @param adspotId adspotId
/// @param appId appId
/// @param mediaKey mediaKey
/// @param resultBlock 结果回调
+ (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
               resultBlock:(void (^ _Nullable)(NSError *error, MercuryAdModel *adModel))resultBlock {
    [self loadAdWithAdspotId:adspotId appId:appId mediaKey:mediaKey fetchDelay:3 resultBlock:resultBlock];
}

/// 发起广告请求
/// @param adspotId adspotId
/// @param appId appId
/// @param mediaKey mediaKey
/// @param fetchDelay 设定超时时间
/// @param resultBlock 结果回调
+ (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
                fetchDelay:(NSTimeInterval)fetchDelay
               resultBlock:(void (^ _Nullable)(NSError *error, MercuryAdModel *adModel))resultBlock {
    [self loadAdWithAdspotId:adspotId appId:appId mediaKey:mediaKey impsize:1 fetchDelay:fetchDelay resultBlock:resultBlock];
}

/// 发起广告请求
/// @param adspotId adspotId
/// @param appId appId
/// @param mediaKey mediaKey
/// @param impsize 广告数量 默认1
/// @param fetchDelay 设定超时时间
/// @param resultBlock 结果回调
+ (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
                   impsize:(NSInteger)impsize
                fetchDelay:(NSTimeInterval)fetchDelay
               resultBlock:(void (^ _Nullable)(NSError *error, MercuryAdModel *adModel))resultBlock {
    [MercuryApiUtils.sharedInstance loadAdWithAdspotId:adspotId appId:appId mediaKey:mediaKey impsize:impsize fetchDelay:fetchDelay resultBlock:resultBlock];
}

@end

@implementation MercuryImp (Repo)

/// 按照事件上报数据(无点击上报)
/// @param eventType 事件类型
/// @param resultBlock 上报结果回调
- (void)reportWithEventType:(MercuryBaseAdRepoTKEventType)eventType
                resultBlock:(void (^ _Nullable)(BOOL isSuccess, MercuryBaseAdRepoTKEventType eventType))resultBlock {
    [MercuryApiUtils.sharedInstance reportAdImp:self adModel:self.adModel eventType:eventType resultBlock:resultBlock];
}

/// 点击事件上报数据
/// @param beginPoint 手指按下位置
/// @param endPoint 手指抬起位置
/// @param resultBlock 上报结果回调
- (void)reportWithBeginPoint:(CGPoint)beginPoint
                    endPoint:(CGPoint)endPoint
                 resultBlock:(void (^ _Nullable)(BOOL isSuccess, MercuryBaseAdRepoTKEventType eventType))resultBlock {
    [MercuryApiUtils.sharedInstance reportAdImp:self adModel:self.adModel eventType:MercuryBaseAdRepoTKEventTypeClick beginPoint:beginPoint endPoint:endPoint resultBlock:resultBlock];
}

/// 异常上报
- (void)reportErrorWithParams:(NSDictionary *)params
                  resultBlock:(void (^ _Nullable)(BOOL isSuccess))resultBlock {
    [MercuryApiUtils.sharedInstance reportErrorWithParams:params resultBlock:resultBlock];
}

@end

NS_ASSUME_NONNULL_END
