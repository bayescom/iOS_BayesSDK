//
//  BY_HCError.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/17.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCError.h"

NSString * const BY_HCErrorUserInfoKeyURL      = @"BY_HCErrorUserInfoKeyURL";
NSString * const BY_HCErrorUserInfoKeyRequest  = @"BY_HCErrorUserInfoKeyRequest";
NSString * const BY_HCErrorUserInfoKeyResponse = @"BY_HCErrorUserInfoKeyResponse";

@implementation BY_HCError

+ (NSError *)errorForResponseUnavailable:(NSURL *)URL
                                 request:(NSURLRequest *)request
                                response:(NSURLResponse *)response
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (URL) {
        [userInfo setObject:URL forKey:BY_HCErrorUserInfoKeyURL];
    }
    if (request) {
        [userInfo setObject:request forKey:BY_HCErrorUserInfoKeyRequest];
    }
    if (response) {
        [userInfo setObject:response forKey:BY_HCErrorUserInfoKeyResponse];
    }
    NSError *error = [NSError errorWithDomain:@"BY_BTVHTTPCache error"
                                         code:BY_HCErrorCodeResponseUnavailable
                                     userInfo:userInfo];
    return error;
}

+ (NSError *)errorForUnsupportContentType:(NSURL *)URL
                                  request:(NSURLRequest *)request
                                 response:(NSURLResponse *)response
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (URL) {
        [userInfo setObject:URL forKey:BY_HCErrorUserInfoKeyURL];
    }
    if (request) {
        [userInfo setObject:request forKey:BY_HCErrorUserInfoKeyRequest];
    }
    if (response) {
        [userInfo setObject:response forKey:BY_HCErrorUserInfoKeyResponse];
    }
    NSError *error = [NSError errorWithDomain:@"BY_BTVHTTPCache error"
                                         code:BY_HCErrorCodeUnsupportContentType
                                     userInfo:userInfo];
    return error;
}

+ (NSError *)errorForNotEnoughDiskSpace:(long long)totlaContentLength
                                request:(long long)currentContentLength
                       totalCacheLength:(long long)totalCacheLength
                         maxCacheLength:(long long)maxCacheLength
{
    NSError *error = [NSError errorWithDomain:@"BY_BTVHTTPCache error"
                                         code:BY_HCErrorCodeNotEnoughDiskSpace
                                     userInfo:@{@"totlaContentLength" : @(totlaContentLength),
                                                @"currentContentLength" : @(currentContentLength),
                                                @"totalCacheLength" : @(totalCacheLength),
                                                @"maxCacheLength" : @(maxCacheLength)}];
    return error;
}

+ (NSError *)errorForException:(NSException *)exception
{
    NSError *error = [NSError errorWithDomain:@"BY_BTVHTTPCache error"
                                        code:BY_HCErrorCodeException
                                    userInfo:exception.userInfo];
    return error;
}


@end
