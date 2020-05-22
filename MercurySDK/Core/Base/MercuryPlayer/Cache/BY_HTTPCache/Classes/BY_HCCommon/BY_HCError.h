//
//  BY_HCError.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/17.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BY_HCErrorCode) {
    BY_HCErrorCodeResponseUnavailable  = -192700,
    BY_HCErrorCodeUnsupportContentType = -192701,
    BY_HCErrorCodeNotEnoughDiskSpace   = -192702,
    BY_HCErrorCodeException            = -192703,
};

@interface BY_HCError : NSObject

+ (NSError *)errorForResponseUnavailable:(NSURL *)URL
                                 request:(NSURLRequest *)request
                                response:(NSURLResponse *)response;

+ (NSError *)errorForUnsupportContentType:(NSURL *)URL
                                  request:(NSURLRequest *)request
                                 response:(NSURLResponse *)response;

+ (NSError *)errorForNotEnoughDiskSpace:(long long)totlaContentLength
                                request:(long long)currentContentLength
                       totalCacheLength:(long long)totalCacheLength
                         maxCacheLength:(long long)maxCacheLength;

+ (NSError *)errorForException:(NSException *)exception;

@end
