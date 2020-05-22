//
//  BY_HCDataResponse.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/24.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCRange.h"

@interface BY_HCDataResponse : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSDictionary *headers;
@property (nonatomic, copy, readonly) NSString *contentType;
@property (nonatomic, copy, readonly) NSString *contentRangeString;
@property (nonatomic, readonly) BY_HCRange contentRange;
@property (nonatomic, readonly) long long contentLength;
@property (nonatomic, readonly) long long totalLength;

@end
