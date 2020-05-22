//
//  MercuryError.h
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MercuryResultCode) {
    /// 自定义异常
    MercuryResultCode__1    =    -1,
    /// 广告被意外终止
    MercuryResultCode__2    =    -2,
    /// 广告位参数错误
    MercuryResultCode100    =    100,
//    /// 权限配置错误
//    MercuryResultCode101    =    101,
//    /// 权限申请失败
//    MercuryResultCode102    =    102,
    /// SDK初始化失败
    MercuryResultCode103    =    103,
    /// SDK异常退出
    MercuryResultCode104    =    104,
    /// 广告返回成功
    MercuryResultCode200    =    200,
    /// 无广告返回
    MercuryResultCode204    =    204,
    /// 广告返回内容解析失败
    MercuryResultCode210    =    210,
    /// 广告返回类型与请求不符
    MercuryResultCode211    =    211,
    /// 广告请求网络失败
    MercuryResultCode212    =    212,
    /// 广告请求超时
    MercuryResultCode213    =    213,
    /// 广告服务器错误
    MercuryResultCode214    =    214,
    /// 广告预加载失败
    MercuryResultCode215    =    215,
    /// 广告素材加载失败
    MercuryResultCode300    =    300,
    /// 广告素材渲染失败
    MercuryResultCode301    =    301,
    /// 广告素材请求超时
    MercuryResultCode302    =    302,
};

NS_ASSUME_NONNULL_BEGIN

@interface MercuryError : NSObject

@property (nonatomic, assign, readonly) MercuryResultCode code;
@property (nonatomic, copy, readonly) NSString *desc;

+ (instancetype)errorWitherror:(MercuryResultCode)code;

+ (instancetype)errorWitherror:(MercuryResultCode)code
                             reqId:(NSString * _Nullable)reqId
                          adspotid:(NSString * _Nullable)adspotid
                           mediaId:(NSString * _Nullable)mediaId;

/// 通过code构造异常对象，如code不在本地错误表中，则将msg中的信息作为上报信息
/// @param code 错误码
/// @param msg 如code不在本地错误表中，则将msg中的信息作为上报信息
+ (instancetype)errorWitherror:(MercuryResultCode)code
                               msg:(NSString *)msg;

+ (instancetype)errorWitherror:(MercuryResultCode)code
                               msg:(NSString  * _Nullable)msg
                         timestamp:(NSTimeInterval)timestamp
                             reqId:(NSString * _Nullable)reqId
                          adspotid:(NSString * _Nullable)adspotid
                           mediaid:(NSString * _Nullable)mediaid;

- (NSError *)toNSError;
- (void)repoErrorCompleted:(void (^)(BOOL isSuccess))completed;

+ (NSDictionary *)errorCodeMap;

@end

NS_ASSUME_NONNULL_END
