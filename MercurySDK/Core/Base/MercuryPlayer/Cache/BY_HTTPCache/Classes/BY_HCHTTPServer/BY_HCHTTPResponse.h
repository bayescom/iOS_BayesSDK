//
//  BY_HCHTTPResponse.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/10.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCHTTPHeader.h"

@class BY_HCHTTPConnection;
@class BY_HCDataRequest;

@interface BY_HCHTTPResponse : NSObject <BY_HTTPResponse>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithConnection:(BY_HCHTTPConnection *)connection dataRequest:(BY_HCDataRequest *)dataRequest NS_DESIGNATED_INITIALIZER;

@end
