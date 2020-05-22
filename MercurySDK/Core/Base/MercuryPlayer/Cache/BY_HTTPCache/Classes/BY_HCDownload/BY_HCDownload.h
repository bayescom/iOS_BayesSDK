//
//  BY_HCDataDownload.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/12.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCDataResponse.h"
#import "BY_HCDataRequest.h"
#import "BY_HCMacro.h"

BY_BTVHTTPCACHE_EXTERN NSString * const BY_HCContentTypeVideo;
BY_BTVHTTPCACHE_EXTERN NSString * const BY_HCContentTypeAudio;
BY_BTVHTTPCACHE_EXTERN NSString * const BY_HCContentTypeApplicationMPEG4;
BY_BTVHTTPCACHE_EXTERN NSString * const BY_HCContentTypeApplicationOctetStream;
BY_BTVHTTPCACHE_EXTERN NSString * const BY_HCContentTypeBinaryOctetStream;

@class BY_HCDownload;

@protocol BY_HCDownloadDelegate <NSObject>

- (void)ktv_download:(BY_HCDownload *)download didCompleteWithError:(NSError *)error;
- (void)ktv_download:(BY_HCDownload *)download didReceiveResponse:(BY_HCDataResponse *)response;
- (void)ktv_download:(BY_HCDownload *)download didReceiveData:(NSData *)data;

@end

@interface BY_HCDownload : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)download;

@property (nonatomic) NSTimeInterval timeoutInterval;

/**
 *  Header Fields
 */
@property (nonatomic, copy) NSArray<NSString *> *whitelistHeaderKeys;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *additionalHeaders;

/**
 *  Content-Type
 */
@property (nonatomic, copy) NSArray<NSString *> *acceptableContentTypes;
@property (nonatomic, copy) BOOL (^unacceptableContentTypeDisposer)(NSURL *URL, NSString *contentType);

- (NSURLSessionTask *)downloadWithRequest:(BY_HCDataRequest *)request delegate:(id<BY_HCDownloadDelegate>)delegate;

@end
