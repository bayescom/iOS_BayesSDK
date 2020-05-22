//
//  MercuryPlayerLogManager.m
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import "MercuryPlayerLogManager.h"

static BOOL kLogEnable = NO;

@implementation MercuryPlayerLogManager

+ (void)setLogEnable:(BOOL)enable {
    kLogEnable = enable;
}

+ (BOOL)getLogEnable {
    return kLogEnable;
}

+ (NSString *)version {
    return @"3.3.1";
}

+ (void)logWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString {
    if ([self getLogEnable]) {
        NSLog(@"%s[%d]%@", function, lineNumber, formatString);
    }
}

@end
