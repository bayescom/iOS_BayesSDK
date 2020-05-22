#import "BY_DDRange.h"
#import "BY_DDNumber.h"

BY_DDRange BY_DDUnionRange(BY_DDRange range1, BY_DDRange range2)
{
	BY_DDRange result;
	
	result.location = MIN(range1.location, range2.location);
	result.length   = MAX(BY_DDMaxRange(range1), BY_DDMaxRange(range2)) - result.location;
	
	return result;
}

BY_DDRange BY_DDIntersectionRange(BY_DDRange range1, BY_DDRange range2)
{
	BY_DDRange result;
	
	if((BY_DDMaxRange(range1) < range2.location) || (BY_DDMaxRange(range2) < range1.location))
	{
		return BY_DDMakeRange(0, 0);
	}
	
	result.location = MAX(range1.location, range2.location);
	result.length   = MIN(BY_DDMaxRange(range1), BY_DDMaxRange(range2)) - result.location;
	
	return result;
}

NSString *BY_DDStringFromRange(BY_DDRange range)
{
	return [NSString stringWithFormat:@"{%qu, %qu}", range.location, range.length];
}

BY_DDRange BY_DDRangeFromString(NSString *aString)
{
	BY_DDRange result = BY_DDMakeRange(0, 0);
	
	// NSRange will ignore '-' characters, but not '+' characters
	NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
	
	NSScanner *scanner = [NSScanner scannerWithString:aString];
	[scanner setCharactersToBeSkipped:[cset invertedSet]];
	
	NSString *str1 = nil;
	NSString *str2 = nil;
	
	BOOL found1 = [scanner scanCharactersFromSet:cset intoString:&str1];
	BOOL found2 = [scanner scanCharactersFromSet:cset intoString:&str2];
	
	if(found1) [NSNumber parseString:str1 intoUInt64:&result.location];
	if(found2) [NSNumber parseString:str2 intoUInt64:&result.length];
	
	return result;
}

NSInteger BY_DDRangeCompare(BY_DDRangePointer pBY_DDRange1, BY_DDRangePointer pBY_DDRange2)
{
	// Comparison basis:
	// Which range would you encouter first if you started at zero, and began walking towards infinity.
	// If you encouter both ranges at the same time, which range would end first.
	
	if(pBY_DDRange1->location < pBY_DDRange2->location)
	{
		return NSOrderedAscending;
	}
	if(pBY_DDRange1->location > pBY_DDRange2->location)
	{
		return NSOrderedDescending;
	}
	if(pBY_DDRange1->length < pBY_DDRange2->length)
	{
		return NSOrderedAscending;
	}
	if(pBY_DDRange1->length > pBY_DDRange2->length)
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

@implementation NSValue (NSValueBY_DDRangeExtensions)

+ (NSValue *)valueWithBY_DDRange:(BY_DDRange)range
{
	return [NSValue valueWithBytes:&range objCType:@encode(BY_DDRange)];
}

- (BY_DDRange)ddrangeValue
{
	BY_DDRange result;
	[self getValue:&result];
	return result;
}

- (NSInteger)ddrangeCompare:(NSValue *)other
{
	BY_DDRange r1 = [self ddrangeValue];
	BY_DDRange r2 = [other ddrangeValue];
	
	return BY_DDRangeCompare(&r1, &r2);
}

@end
