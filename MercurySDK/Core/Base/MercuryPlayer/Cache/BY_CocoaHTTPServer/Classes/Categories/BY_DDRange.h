/**
 * BY_DDRange is the functional equivalent of a 64 bit NSRange.
 * The HTTP Server is designed to support very large files.
 * On 32 bit architectures (ppc, i386) NSRange uses unsigned 32 bit integers.
 * This only supports a range of up to 4 gigabytes.
 * By defining our own variant, we can support a range up to 16 exabytes.
 * 
 * All effort is given such that BY_DDRange functions EXACTLY the same as NSRange.
**/

#import <Foundation/NSValue.h>
#import <Foundation/NSObjCRuntime.h>

@class NSString;

typedef struct _BY_DDRange {
    UInt64 location;
    UInt64 length;
} BY_DDRange;

typedef BY_DDRange *BY_DDRangePointer;

NS_INLINE BY_DDRange BY_DDMakeRange(UInt64 loc, UInt64 len) {
    BY_DDRange r;
    r.location = loc;
    r.length = len;
    return r;
}

NS_INLINE UInt64 BY_DDMaxRange(BY_DDRange range) {
    return (range.location + range.length);
}

NS_INLINE BOOL BY_DDLocationInRange(UInt64 loc, BY_DDRange range) {
    return (loc - range.location < range.length);
}

NS_INLINE BOOL BY_DDEqualRanges(BY_DDRange range1, BY_DDRange range2) {
    return ((range1.location == range2.location) && (range1.length == range2.length));
}

FOUNDATION_EXPORT BY_DDRange BY_DDUnionRange(BY_DDRange range1, BY_DDRange range2);
FOUNDATION_EXPORT BY_DDRange BY_DDIntersectionRange(BY_DDRange range1, BY_DDRange range2);
FOUNDATION_EXPORT NSString *BY_DDStringFromRange(BY_DDRange range);
FOUNDATION_EXPORT BY_DDRange BY_DDRangeFromString(NSString *aString);

NSInteger BY_DDRangeCompare(BY_DDRangePointer pBY_DDRange1, BY_DDRangePointer pBY_DDRange2);

@interface NSValue (NSValueBY_DDRangeExtensions)

+ (NSValue *)valueWithBY_DDRange:(BY_DDRange)range;
- (BY_DDRange)ddrangeValue;

- (NSInteger)ddrangeCompare:(NSValue *)ddrangeValue;

@end
