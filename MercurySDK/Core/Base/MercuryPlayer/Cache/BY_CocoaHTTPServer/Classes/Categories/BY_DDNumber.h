#import <Foundation/Foundation.h>


@interface NSNumber (BY_DDNumber)

+ (BOOL)parseString:(NSString *)str intoSInt64:(SInt64 *)pNum;
+ (BOOL)parseString:(NSString *)str intoUInt64:(UInt64 *)pNum;

+ (BOOL)parseString:(NSString *)str intoNSInteger:(NSInteger *)pNum;
+ (BOOL)parseString:(NSString *)str intoNSUInteger:(NSUInteger *)pNum;

@end
