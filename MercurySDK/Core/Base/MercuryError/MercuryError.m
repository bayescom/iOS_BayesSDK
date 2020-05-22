//
//  MercuryError.m
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryError.h"
#import "NSDictionary+Mercury.h"
#import "MercuryDeviceInfoUtil.h"
#import "MercuryLog.h"

@interface MercuryError ()
@property (nonatomic, assign) MercuryResultCode code;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, strong) NSMutableDictionary *paramsM;

@end

@implementation MercuryError

+ (instancetype)errorWitherror:(MercuryResultCode)code {
    return [self errorWitherror:code msg:@""];
}

+ (instancetype)errorWitherror:(MercuryResultCode)code msg:(NSString *)msg {
    return [self errorWitherror:code
                                msg:msg
                          timestamp:[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000
                              reqId:nil
                           adspotid:nil
                            mediaid:[MercuryDeviceInfoUtil sharedInstance].mediaKey];
}

+ (instancetype)errorWitherror:(MercuryResultCode)code
                             reqId:(NSString * _Nullable)reqId
                          adspotid:(NSString * _Nullable)adspotid
                            mediaId:(NSString * _Nullable)mediaId {
    return [self errorWitherror:code
                                msg:@""
                          timestamp:[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000
                              reqId:reqId
                           adspotid:adspotid
                            mediaid:mediaId];
}

+ (instancetype)errorWitherror:(MercuryResultCode)code
                               msg:(NSString *)msg
                         timestamp:(NSTimeInterval)timestamp
                             reqId:(NSString *)reqId
                          adspotid:(NSString *)adspotid
                           mediaid:(NSString *)mediaid {
    MercuryError *bError = [[MercuryError alloc] init];
    bError.code = code;
    bError.desc = [MercuryError getCodeDesc:code];
    if (bError.desc.length <= 0) {  // 如果错误码在本地错误码列表中不存在，将服务器信息放入desc中
        bError.desc = msg;
    }
    bError.paramsM = [NSMutableDictionary dictionary];
    if (reqId) { [bError.paramsM setObject:reqId forKey:@"reqId"]; }
    if (adspotid) { [bError.paramsM setObject:adspotid forKey:@"adspotid"]; }
    if (mediaid) { [bError.paramsM setObject:mediaid forKey:@"mediaid"]; }
    if (bError.desc) { [bError.paramsM setObject:bError.desc forKey:@"msg"]; }
    if (timestamp>0) {
        [bError.paramsM setObject:@(timestamp) forKey:@"timestamp"];
    }
    [bError.paramsM setObject:@((int)bError.code) forKey:@"code"];
    [bError repoErrorCompleted:^(BOOL isSuccess) {
        if (isSuccess) {
            MercuryLog(@"异常上报成功 => %@", bError.paramsM);
        } else {
            MercuryLog(@"异常上报失败 => %@", bError.paramsM);
        }
    }];
    return bError;
}

- (NSError *)toNSError {
    NSError *error = [NSError errorWithDomain:@"com.MercuryError.Mercury" code:self.code userInfo:@{
        @"errorMsg": self.desc
    }];
    return error;
}

- (void)repoErrorCompleted:(void (^)(BOOL isSuccess))completed {
    if ([self needUpToService]) {
        // TODO: 上传回调后，执行completed
//        [[MercuryApiUtils sharedInstance] reportErrorWithParams:[self.paramsM copy] resultBlock:completed];
    } else {
        if (completed) { completed(NO); }
    }
}

/// 判断此错误是否需要被上报到服务器 YES表示需要被上传到服务器
- (BOOL)needUpToService {
    // 此类型异常不提交到服务器
    if (_code == MercuryResultCode__1 ||
        _code == MercuryResultCode204 ||
        _code == MercuryResultCode212 ||
        _code == MercuryResultCode213) {
        return NO;
    }
    return YES;
}

// MARK: ======================= 错误对照表 =======================
+ (NSString *)getCodeDesc:(MercuryResultCode)code {
    return [[MercuryError errorCodeMap] mercury_objectForKeyNotNil:@(code)];
}

+ (NSDictionary *)errorCodeMap {
    return @{
        @(MercuryResultCode__2) : @"广告被意外终止",
        @(MercuryResultCode100) : @"广告位参数错误",
//        @(MercuryResultCode101) : @"权限配置错误",
//        @(MercuryResultCode102) : @"权限申请失败",
        @(MercuryResultCode103) : @"SDK初始化失败",
//        @(MercuryResultCode104) : @"SDK异常退出",
        @(MercuryResultCode200) : @"广告返回成功",
        @(MercuryResultCode204) : @"无广告返回",
        @(MercuryResultCode210) : @"广告返回内容解析失败",
        @(MercuryResultCode211) : @"广告返回类型与请求不符",
        @(MercuryResultCode212) : @"广告请求网络失败",
        @(MercuryResultCode213) : @"广告请求超时",
        @(MercuryResultCode214) : @"广告服务器错误",
        @(MercuryResultCode215) : @"广告预加载失败",
        @(MercuryResultCode300) : @"广告素材加载失败",
        @(MercuryResultCode301) : @"广告素材渲染失败",
        @(MercuryResultCode302) : @"广告素材请求超时",
    };
}

@end
