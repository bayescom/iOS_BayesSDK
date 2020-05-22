//
//  BY_HCDataUnit.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCDataUnitItem.h"

@class BY_HCDataUnit;

@protocol BY_HCDataUnitDelegate <NSObject>

- (void)ktv_unitDidChangeMetadata:(BY_HCDataUnit *)unit;

@end

@interface BY_HCDataUnit : NSObject <NSCoding, NSLocking>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithURL:(NSURL *)URL;

@property (nonatomic, copy, readonly) NSError *error;

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSURL *completeURL;
@property (nonatomic, copy, readonly) NSString *key;       // Unique Identifier.
@property (nonatomic, copy, readonly) NSDictionary *responseHeaders;
@property (nonatomic, readonly) NSTimeInterval createTimeInterval;
@property (nonatomic, readonly) NSTimeInterval lastItemCreateInterval;
@property (nonatomic, readonly) long long totalLength;
@property (nonatomic, readonly) long long cacheLength;
@property (nonatomic, readonly) long long validLength;

/**
 *  Unit Item
 */
- (NSArray<BY_HCDataUnitItem *> *)unitItems;
- (void)insertUnitItem:(BY_HCDataUnitItem *)unitItem;

/**
 *  Info Sync
 */
- (void)updateResponseHeaders:(NSDictionary *)responseHeaders totalLength:(long long)totalLength;

/**
 *  Working
 */
@property (nonatomic, readonly) NSInteger workingCount;

- (void)workingRetain;
- (void)workingRelease;

/**
 *  File Control
 */
@property (nonatomic, weak) id <BY_HCDataUnitDelegate> delegate;

- (void)deleteFiles;

@end
