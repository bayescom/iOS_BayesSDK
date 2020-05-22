//
//  MercuryApiUtils.m
//  AAA
//
//  Created by CherryKing on 2019/10/30.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryApiUtils.h"
#import "MercuryPriHeader.h"
#import <WebKit/WebKit.h>
#import "MercuryDeviceInfoUtil.h"
#import "MercuryReachability.h"
#import "MercuryAdModel.h"

#import "NSDictionary+Mercury.h"
#import "NSMutableDictionary+Mercury.h"
#import "MercuryLog.h"

//#import "MercuryPreloadMediaInfo.h"
//#import "MercuryPreloadMediaManager.h"

@interface MercuryApiUtils ()

@end

@implementation MercuryApiUtils
// MARK: BSDK单例
static MercuryApiUtils *_instance = nil;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

+ (id) allocWithZone:(struct _NSZone *)zone {
    return [MercuryApiUtils sharedInstance] ;
}

- (id) copyWithZone:(struct _NSZone *)zone {
    return [MercuryApiUtils sharedInstance] ;
}

// MARK: Public
/// ============================================== 请求广告数据
- (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
               resultBlock:(void (^)(NSError *error, MercuryAdModel *adModel))resultBlock {
    [self loadAdWithAdspotId:adspotId appId:appId mediaKey:mediaKey fetchDelay:3 resultBlock:resultBlock];
}

- (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
                   impsize:(NSInteger)impsize
                fetchDelay:(NSTimeInterval)fetchDelay
               resultBlock:(void (^)(NSError *error, MercuryAdModel *adModel))resultBlock {
    
//    NSString *s = nil;
//    @{s: s};
    
    if (MercuryDeviceInfoUtil.sharedInstance.appId.length <= 0 ||
        MercuryDeviceInfoUtil.sharedInstance.mediaKey.length <= 0) {    // SDK 配置校验
        if (resultBlock) { resultBlock([MercuryError errorWitherror:MercuryResultCode103].toNSError, nil); }
        return;
    }
//    [MercuryReachability curr
    MercuryReachability *reach = [MercuryReachability reachabilityForInternetConnection];
    if (reach.currentReachabilityStatus == MercuryNetworkStatusNotReachable) {     // 网络不可用检测
        if (resultBlock) { resultBlock([MercuryError errorWitherror:MercuryResultCode212].toNSError, nil); }
        return;
    }
    if (fetchDelay<=0) { fetchDelay = kMercury_FetchDelay; }
    if (impsize<=0) { impsize = 1; }
//    NSDictionary *deviceInfoDic = [[MercuryDeviceInfoUtil sharedInstance] getDeviceInfoWithAdspotId:adspotId appId:appId mediaKey:mediaKey];
    [[MercuryDeviceInfoUtil sharedInstance] getDeviceInfoWithAdspotId:adspotId appId:appId mediaKey:mediaKey completion:^(NSDictionary * _Nonnull deviceInfo) {
        /// 移除定位信息
        NSMutableDictionary *deviceInfoDicM = [NSMutableDictionary dictionaryWithDictionary:deviceInfo];
        [deviceInfoDicM setValue:@(impsize) forKey:@"impsize"];
        [self fetchDataWithDeviceInfo:[deviceInfoDicM copy]
                           fetchDelay:fetchDelay
                          resultBlock:resultBlock];
    }];
}

- (void)loadAdWithAdspotId:(NSString *)adspotId
                     appId:(NSString *)appId
                  mediaKey:(NSString *)mediaKey
                fetchDelay:(NSTimeInterval)fetchDelay
               resultBlock:(void (^)(NSError *error, MercuryAdModel *adModel))resultBlock {
    [self loadAdWithAdspotId:adspotId appId:appId mediaKey:mediaKey impsize:1 fetchDelay:fetchDelay resultBlock:resultBlock];
}

- (void)fetchDataWithDeviceInfo:(NSDictionary *)deviceInfo
                     fetchDelay:(NSTimeInterval)fetchDelay
                    resultBlock:(void (^)(NSError *error, MercuryAdModel *adModel))resultBlock {
    //encode as json
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    
    #if kIsMockFlag
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@raddus?adspotId=%@", Mercury_POST_URL, [deviceInfo objectForKey:@"adspotid"]]];
    #else
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@raddus", Mercury_POST_URL]];
    #endif
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:
                                    NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:fetchDelay];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[MercuryDeviceInfoUtil sharedInstance].ua forHTTPHeaderField:@"User-Agent"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    //use share session
    NSURLSession *sharedSession = [NSURLSession sharedSession];

    //use system dataTask
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
                                                      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        if (data && (error == nil)) {   // response success
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if (httpResp.statusCode != MercuryResultCode200) {
                mer_dispatch_main_safe_async(^{ // 请求错误
                    if (resultBlock) {
                        MercuryError *error = [MercuryError errorWitherror:httpResp.statusCode
                                                                 msg:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                                                           timestamp:[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000
                                                               reqId:[deviceInfo mercury_objectForKeyNotNil:@"reqid"]
                                                            adspotid:[deviceInfo mercury_objectForKeyNotNil:@"adspotid"]
                                                             mediaid:[deviceInfo mercury_objectForKeyNotNil:@"appid"]];
                        resultBlock(error.toNSError, nil);
                    }
                });
            } else {
                NSError *jsonError;
                MercuryAdModel *model = [MercuryAdModel fromData:data error:&jsonError];
                model.adResponseTimeStamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
                model.reqId = [deviceInfo mercury_objectForKeyNotNil:@"reqid"];
                model.adspotId = [deviceInfo mercury_objectForKeyNotNil:@"adspotid"];
                model.mediaId = [deviceInfo mercury_objectForKeyNotNil:@"appid"];
                
                mer_dispatch_main_safe_async(^{
                    if (jsonError) {
                        // TODO: 解析错误
                        if (resultBlock) {
                            MercuryError *error = [MercuryError errorWitherror:MercuryResultCode210
                                                                     msg:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                                                               timestamp:[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000
                                                                   reqId:[deviceInfo mercury_objectForKeyNotNil:@"reqid"]
                                                                adspotid:[deviceInfo mercury_objectForKeyNotNil:@"adspotid"]
                                                                 mediaid:[deviceInfo mercury_objectForKeyNotNil:@"appid"]];
                            resultBlock(error.toNSError, nil);
                        }
                    } else if (model.code == MercuryResultCode200) {
                        if (model.imp.count<=0) {
                            MercuryError *error = [MercuryError errorWitherror:MercuryResultCode204
                                                                     msg:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                                                               timestamp:model.adResponseTimeStamp
                                                                   reqId:model.reqId
                                                                adspotid:model.adspotId
                                                                 mediaid:model.mediaId];
                            resultBlock(error.toNSError, model);
                        } else {
                            if (resultBlock) { resultBlock(nil, model); }
                        }
                    } else {
                        if (resultBlock) {
                            MercuryError *error = [MercuryError errorWitherror:model.code
                                                                     msg:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                                                               timestamp:model.adResponseTimeStamp
                                                                   reqId:model.reqId
                                                                adspotid:model.adspotId
                                                                 mediaid:model.mediaId];
                            resultBlock(error.toNSError, model);
                        }
                    }
                });
            }
            
        } else {
            // 这里执行网络错误
            mer_dispatch_main_safe_async(^{
                if (error.code == -1001) {  // time out
                    if (resultBlock) {
                        MercuryError *error = [MercuryError errorWitherror:MercuryResultCode213
                                                                 msg:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                                                           timestamp:[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000
                                                               reqId:[deviceInfo mercury_objectForKeyNotNil:@"reqid"]
                                                            adspotid:[deviceInfo mercury_objectForKeyNotNil:@"adspotid"]
                                                             mediaid:[deviceInfo mercury_objectForKeyNotNil:@"appid"]];
                        resultBlock(error.toNSError, nil);
                    }
                    
                } else {
                    if (resultBlock) { resultBlock(error, nil); }
                }
            });
        }
    }];
    [dataTask resume];
}

// MARK: ======================= 预缓存资源 =======================
- (void)preloadedResourcesIfNeed {
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/cache", Mercury_POST_URL]];
////    NSURL *url = [NSURL URLWithString:@"http://raddus.bayescom.com/cache"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
////    [request setValue:[MercuryDeviceInfoUtil sharedInstance].ua forHTTPHeaderField:@"User-Agent"];
//
//    NSDictionary *params = @{
//        @"appid": MercuryAppId,
//        @"os": @"-1",
//        @"idfa": [MercuryDeviceInfoUtil getIdfa],
//    };
//
//    NSError *parseError = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&parseError];
//
//    request.HTTPMethod = @"POST";
//    request.HTTPBody = jsonData;
//    //use share session
//    NSURLSession *sharedSession = [NSURLSession sharedSession];
//    //use system dataTask
//    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
//                                                      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
//        // NSURLSession multi thread
//        if (error == nil) {
//            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
//            dispatch_main_safe_async(^{
//                if (httpResp.statusCode == MercuryResultCode200) {    // Success
//                    NSError *jsonError;
//                    MercuryPreloadMediaInfo *model = [MercuryPreloadMediaInfo fromData:data error:&jsonError];
//                    if (!jsonError && model) {
//                        if (model.code == MercuryResultCode200) {
//                            [[MercuryPreloadMediaManager manager] saveInfoAndPreload:model];
//                        } else {
//                            [MercuryError errorWitherror:MercuryResultCode215
//                                                    msg:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
//                                              timestamp:[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000
//                                                  reqId:@""
//                                               adspotid:@""
//                                                mediaid:MercuryAppId];
//                        }
//                    }
//                }
//            });
//        } else {
////            if (resultBlock) { resultBlock(NO); }
//        }
//    }];
//    [dataTask resume];
}

// MARK: ======================= 数据上报 =======================
- (void)reportAdImp:(MercuryImp *)adImp
            adModel:(MercuryAdModel *)adModel
          eventType:(MercuryBaseAdRepoTKEventType)eventType
            resultBlock:(void (^)(BOOL isSuccess, MercuryBaseAdRepoTKEventType eventType))resultBlock {
    [self reportAdImp:adImp adModel:adModel eventType:eventType beginPoint:CGPointZero endPoint:CGPointZero resultBlock:resultBlock];
}

- (void)reportAdImp:(MercuryImp *)adImp
            adModel:(MercuryAdModel *)adModel
          eventType:(MercuryBaseAdRepoTKEventType)eventType
         beginPoint:(CGPoint)beginPoint
           endPoint:(CGPoint)endPoint
        resultBlock:(void (^)(BOOL isSuccess, MercuryBaseAdRepoTKEventType eventType))resultBlock {
    if (!adImp || !adModel) {
        if (resultBlock) { resultBlock(YES, eventType); }
// MercuryLog(@"上报数据异常");
        return;
    }
    NSString *ua = [MercuryDeviceInfoUtil sharedInstance].ua;
    NSArray<NSString *> *uploadArr = nil;
    /// 按照类型判断上报地址
    if (eventType == MercuryBaseAdRepoTKEventTypeShow) { // 曝光上报
        uploadArr = adImp.imptk;
        if (adImp.isExposuredRepo == YES) { return; }
        adImp.isExposuredRepo = YES;
    } else if (eventType == MercuryBaseAdRepoTKEventTypeClick) { // 点击上报
        uploadArr = adImp.clicktk;
        if (adImp.isClickedRepo == YES) { return; }
        adImp.isClickedRepo = YES;
    } else if (eventType == MercuryBaseAdRepoTKEventTypeVideoStart) { // 视频开始播放上报
        uploadArr = adImp.starttk;
        if (adImp.isVStartRepo == YES) { return; }
        adImp.isVStartRepo = YES;
    } else if (eventType == MercuryBaseAdRepoTKEventTypeVideoMid) { // 视频播放到一半上报
        uploadArr = adImp.midtk;
        if (adImp.isVMidRepo == YES) { return; }
        adImp.isVMidRepo = YES;
    } else if (eventType == MercuryBaseAdRepoTKEventTypeVideoEnd) { // 视频播放结束
        uploadArr = adImp.endtk;
        if (adImp.isVEndRepo == YES) { return; }
        adImp.isVEndRepo = YES;
    } else if (eventType == MercuryBaseAdRepoTKEventTypeVideo1_4) { // 视频播放到1/4
        uploadArr = adImp.firsttk;
        if (adImp.isVFirstRepo == YES) { return; }
        adImp.isVFirstRepo = YES;
    } else if (eventType == MercuryBaseAdRepoTKEventTypeVideo3_4) { // 视频播放到3/4
        uploadArr = adImp.thirdtk;
        if (adImp.isVThirdRepo == YES) { return; }
        adImp.isVThirdRepo = YES;
    } else if (eventType == MercuryBaseAdRepoTKEventTypeSkip) { // 开屏点击跳过上报
        uploadArr = adImp.skiptk;
        if (adImp.isSkipRepo == YES) { return; }
        adImp.isSkipRepo = YES;
    } else if (eventType == MercuryBaseAdRepoTKEventTypeLink) { // link成功调起上报地址
        uploadArr = adImp.linktk;
        if (adImp.isLinkRepo == YES) { return; }
        adImp.isLinkRepo = YES;
    } else if (eventType == MercuryBaseAdRepoTKEventTypeDeeplink) { // deeplink成功调起上报地址
        uploadArr = adImp.deeplinktk;
        if (adImp.isDpLinkRepo == YES) { return; }
        adImp.isDpLinkRepo = YES;
    }
    if (!uploadArr || uploadArr.count <= 0) {
        // TODO: 上报地址不存在，如何处理忽略还是回调错误
    }
    for (id obj in uploadArr) {
        NSURL *url = [NSURL URLWithString:[self replaceReportMacro:obj adModel:adModel adImp:adImp eventType:eventType beginPoint:beginPoint endPoint:endPoint]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:
                NSURLRequestReloadIgnoringLocalCacheData   timeoutInterval:5];
        [request setValue:ua forHTTPHeaderField:@"User-Agent"];
        request.HTTPMethod = @"GET";
        //use share session
        NSURLSession *sharedSession = [NSURLSession sharedSession];
        //use system dataTask
        NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
                                                          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            // NSURLSession multi thread
            if (error == nil) {
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
                mer_dispatch_main_safe_async(^{
                    if (httpResp.statusCode == MercuryResultCode200) {    // Success
                        if (resultBlock) { resultBlock(YES, eventType); }
                    } else {
                        if (resultBlock) { resultBlock(NO, eventType); }
                    }
                });
            } else {
                if (resultBlock) { resultBlock(NO, eventType); }
            }
        }];
        [dataTask resume];
    }
    MercuryLog(@"%@ = 上报(impid: %@)", MercuryStringFromNMercuryBaseAdRepoTKEventType(eventType), adImp.impid);
}

/// MARK: 根据上报类型上报宏替换
/// @param urlString 上报地址
/// @param adModel 上报的广告
/// @param adImp 上报的创意
/// @param eventType 上报类型
/// @param beginPoint 手指点击位置(起始点)
/// @param endPoint 手指点击位置(结束点)
- (NSString *)replaceReportMacro:(NSString *)urlString
                         adModel:(MercuryAdModel *)adModel
                           adImp:(MercuryImp *)adImp
                       eventType:(MercuryBaseAdRepoTKEventType)eventType
                      beginPoint:(CGPoint)beginPoint
                        endPoint:(CGPoint)endPoint {
    // 处理点击位置
    if (!CGPointEqualToPoint(beginPoint, CGPointZero) ||
        CGPointEqualToPoint(endPoint, CGPointZero)) {
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__DOWN_X__" withString:[NSString stringWithFormat:@"%d", [[NSNumber numberWithFloat:beginPoint.x] intValue]]];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__UP_X__" withString:[NSString stringWithFormat:@"%d", [[NSNumber numberWithFloat:endPoint.x] intValue]]];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__DOWN_Y__" withString:[NSString stringWithFormat:@"%d", [[NSNumber numberWithFloat:beginPoint.y] intValue]]];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__UP_Y__" withString:[NSString stringWithFormat:@"%d", [[NSNumber numberWithFloat:endPoint.y] intValue]]];
    }
    if (eventType == MercuryBaseAdRepoTKEventTypeShow) {
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__RESPONSE_TIME__" withString:[NSString stringWithFormat:@"%0.0f", adModel.adResponseTimeStamp]];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__READY_TIME__" withString:[NSString stringWithFormat:@"%0.0f", adModel.adResponseTimeStamp]];
        NSTimeInterval showTimeStamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__SHOW_TIME__" withString:[NSString stringWithFormat:@"%0.0f", showTimeStamp]];
    }
    if (eventType == MercuryBaseAdRepoTKEventTypeClick) {
        NSTimeInterval clickTimeStamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__CLICK_TIME__" withString:[NSString stringWithFormat:@"%0.0f", clickTimeStamp]];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__WIDTH__" withString:[NSString stringWithFormat:@"%d", [[NSNumber numberWithFloat:adImp.sizeW] intValue]]];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__HEIGHT__" withString:[NSString stringWithFormat:@"%d", [[NSNumber numberWithFloat:adImp.sizeH] intValue]]];
    }
    return urlString;
}

// MARK: ======================= 异常上报 =======================
- (void)reportErrorWithParams:(NSDictionary *)params
                  resultBlock:(void (^)(BOOL isSuccess))resultBlock {
    NSURL *url = [NSURL URLWithString:@"http://raddus.bayescom.com/sdkevent"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    [request setValue:[MercuryDeviceInfoUtil sharedInstance].ua forHTTPHeaderField:@"User-Agent"];
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&parseError];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = jsonData;
    //use share session
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    //use system dataTask
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
                                                      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        // NSURLSession multi thread
        if (error == nil) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
            mer_dispatch_main_safe_async(^{
                if (httpResp.statusCode == MercuryResultCode200) {    // Success
                    if (resultBlock) { resultBlock(YES); }
                } else {
                    if (resultBlock) { resultBlock(NO); }
                }
            });
        } else {
            if (resultBlock) { resultBlock(NO); }
        }
    }];
    [dataTask resume];
}

@end
