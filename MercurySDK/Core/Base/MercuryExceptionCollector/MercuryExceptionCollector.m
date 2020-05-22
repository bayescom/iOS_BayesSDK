//
//  MercuryExceptionCollector.m
//  MercurySDK
//
//  Created by CherryKing on 2019/11/4.
//  Copyright © 2019 Mercury. All rights reserved.
//

#import "MercuryExceptionCollector.h"
#import <UIKit/UIKit.h>
#import "MercuryError.h"

#define kMerExcepitionHappenedEnd   @"================================================================"
#define kMerExcepitionHappenedStart @"========================⚠️⚠️⚠️⚠️⚠️⚠️⚠️========================="

void mercury_handleErrorWithException(NSException * exception) {
    [MercuryExceptionCollector handleErrorWithException:exception];
}

@implementation MercuryExceptionCollector
/**
 简化堆栈信息

 @param callStackSymbols 详细堆栈信息
 @return 简化之后的堆栈信息
 */
+ (NSString *)getMainCallStackSymbolMessageWithCallStackSymbols:(NSArray<NSString *> *)callStackSymbols {
    // mainCallStackSymbolMsg的格式为   +[类名 方法名]  或者 -[类名 方法名]
    __block NSString *mainCallStackSymbolMsg = nil;
    
    // 匹配出来的格式为 +[类名 方法名]  或者 -[类名 方法名]
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    for (int index = 2; index < callStackSymbols.count; index++) {
        NSString *callStackSymbol = callStackSymbols[index];
        [regularExp enumerateMatchesInString:callStackSymbol
                                     options:NSMatchingReportProgress
                                       range:NSMakeRange(0, callStackSymbol.length)
                                  usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                      if (result) {
                                          NSString *tempCallStackSymbolMsg = [callStackSymbol substringWithRange:result.range];

                                          NSString *className = [tempCallStackSymbolMsg componentsSeparatedByString:@" "].firstObject;
                                          className           = [className componentsSeparatedByString:@"["].lastObject;
                                          
                                          NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                                          if (![className hasSuffix:@")"] && bundle == [NSBundle mainBundle]) {
                                              mainCallStackSymbolMsg = tempCallStackSymbolMsg;
                                          }
                                          *stop = YES;
                                      }
                                  }];
        if (mainCallStackSymbolMsg.length) break;
    }
    return mainCallStackSymbolMsg;
}

+ (void)handleErrorWithException:(NSException *)exception {
    // 堆栈数据
    NSArray *callStackSymbolsArr     = [NSThread callStackSymbols];
    // 获取在哪个类的哪个方法中实例化的数组  字符串格式 -[类名 方法名]  或者 +[类名 方法名]
    NSString *mainCallStackSymbolMsg = [self getMainCallStackSymbolMessageWithCallStackSymbols:callStackSymbolsArr];
    
    if (mainCallStackSymbolMsg == nil)  mainCallStackSymbolMsg = @"崩溃方法定位失败,请您查看函数调用栈来排查错误原因";
    
    NSString *errorName   = exception.name;
    NSString *errorReason = exception.reason;
    // errorReason 可能为 -[__NSCFConstantString avoidCrashCharacterAtIndex:]: Range or index out of bounds
    errorReason           = [errorReason stringByReplacingOccurrencesOfString:@"avoidCrash" withString:@""];
    
    // 拼接错误信息
    NSString *errorPlace      = [NSString stringWithFormat:@"Error Place:%@",mainCallStackSymbolMsg];
    NSString *logErrorMessage = [NSString stringWithFormat:@"\n\n%@\n\n%@\n%@\n%@\n",kMerExcepitionHappenedStart, errorName, errorReason, errorPlace];
    logErrorMessage           = [NSString stringWithFormat:@"%@\n\n%@\n\n",logErrorMessage,kMerExcepitionHappenedEnd];
    
//    MercuryLog(@"%@",logErrorMessage);
    
//#if DEBUG
//    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:errorName
//                                                                     message:errorReason
//                                                              preferredStyle:UIAlertControllerStyleAlert];
//    [alertVC addAction:[UIAlertAction actionWithTitle:@"好"
//                                                style:UIAlertActionStyleDefault
//                                              handler:nil]];
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC
//                                                                                 animated:YES
//                                                                               completion:nil];
//#endif
    NSDictionary *errorInfoDic = @{
                                   @"errorName"        : errorName,
                                   @"errorReason"      : errorReason,
                                   @"errorPlace"       : errorPlace,
                                   @"callStackSymbols"        : exception,
                                   @"exception" : callStackSymbolsArr
                                   };
    
    [MercuryError errorWitherror:MercuryResultCode104 msg:[errorInfoDic description]];
    
    // 将错误信息放在字典里，用通知的形式发送出去
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ExcepitionHappenedNotification object:nil userInfo:errorInfoDic];
    });
}
@end
