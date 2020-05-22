
#import "BY_MultipartMessageHeader.h"

/* 
Part one: http://tools.ietf.org/html/rfc2045 (Format of Internet Message Bodies)
Part two: http://tools.ietf.org/html/rfc2046 (Media Types)
Part three: http://tools.ietf.org/html/rfc2047 (Message Header Extensions for Non-ASCII Text)
Part four: http://tools.ietf.org/html/rfc4289 (Registration Procedures) 
Part five: http://tools.ietf.org/html/rfc2049 (Conformance Criteria and Examples) 
 
Internet message format:  http://tools.ietf.org/html/rfc2822

Multipart/form-data http://tools.ietf.org/html/rfc2388
*/

@class BY_MultipartFormDataParser;

//-----------------------------------------------------------------
// protocol BY_MultipartFormDataParser
//-----------------------------------------------------------------

@protocol BY_MultipartFormDataParserDelegate <NSObject> 
@optional
- (void) processContent:(NSData*) data WithHeader:(BY_MultipartMessageHeader*) header;
- (void) processEndOfPartWithHeader:(BY_MultipartMessageHeader*) header;
- (void) processPreambleData:(NSData*) data;
- (void) processEpilogueData:(NSData*) data;
- (void) processStartOfPartWithHeader:(BY_MultipartMessageHeader*) header;
@end

//-----------------------------------------------------------------
// interface BY_MultipartFormDataParser
//-----------------------------------------------------------------

@interface BY_MultipartFormDataParser : NSObject {
NSMutableData*						pendingData;
    NSData*							boundaryData;
    BY_MultipartMessageHeader*			currentHeader;

	BOOL							waitingForCRLF;
	BOOL							reachedEpilogue;
	BOOL							processedPreamble;
	BOOL							checkForContentEnd;

#if __has_feature(objc_arc_weak)
	__weak id<BY_MultipartFormDataParserDelegate>                  delegate;
#else
	__unsafe_unretained id<BY_MultipartFormDataParserDelegate>     delegate;
#endif	
	int									currentEncoding;
	NSStringEncoding					formEncoding;
}

- (BOOL) appendData:(NSData*) data;

- (id) initWithBoundary:(NSString*) boundary formEncoding:(NSStringEncoding) formEncoding;

#if __has_feature(objc_arc_weak)
    @property(weak, readwrite) id delegate;
#else
    @property(unsafe_unretained, readwrite) id delegate;
#endif
@property(readwrite) NSStringEncoding	formEncoding;

@end
