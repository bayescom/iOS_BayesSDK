
#import "BY_MultipartMessageHeaderField.h"
#import "BY_HTTPLogging.h"

//-----------------------------------------------------------------
#pragma mark log level

#ifdef DEBUG
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN;
#else
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN;
#endif


// helpers
int by_findChar(const char* str,NSUInteger length, char c);
NSString* by_extractParamValue(const char* bytes, NSUInteger length, NSStringEncoding encoding);

//-----------------------------------------------------------------
// interface BY_MultipartMessageHeaderField (private)
//-----------------------------------------------------------------


@interface BY_MultipartMessageHeaderField (private)
-(BOOL) parseHeaderValueBytes:(char*) bytes length:(NSUInteger) length encoding:(NSStringEncoding) encoding;
@end


//-----------------------------------------------------------------
// implementation BY_MultipartMessageHeaderField
//-----------------------------------------------------------------

@implementation BY_MultipartMessageHeaderField
@synthesize name,value,params;

- (id) initWithData:(NSData *)data contentEncoding:(NSStringEncoding)encoding {
	params = [[NSMutableDictionary alloc] initWithCapacity:1];

	char* bytes = (char*)data.bytes;
	NSUInteger length = data.length;

	int separatorOffset = by_findChar(bytes, length, ':');
	if( (-1 == separatorOffset) || (separatorOffset >= length-2) ) {
		HTTPLogError(@"BY_MultipartFormDataParser: Bad format.No colon in field header.");
		// tear down
		return nil;
	}
	
	// header name is always ascii encoded;
	name = [[NSString alloc] initWithBytes: bytes length: separatorOffset encoding: NSASCIIStringEncoding];
	if( nil == name ) {
		HTTPLogError(@"BY_MultipartFormDataParser: Bad MIME header name.");
		// tear down
		return nil;		
	}
	
	// skip the separator and the next ' ' symbol
	bytes += separatorOffset + 2;
	length -= separatorOffset + 2;

	separatorOffset = by_findChar(bytes, length, ';');
	if( separatorOffset == -1 ) {
		// couldn't find ';', means we don't have extra params here. 
		value = [[NSString alloc] initWithBytes:bytes length: length encoding:encoding];

		if( nil == value ) {
			HTTPLogError(@"BY_MultipartFormDataParser: Bad MIME header value for header name: '%@'",name);
			// tear down
			return nil;		
		}
		return self;
	}
	
	value = [[NSString alloc] initWithBytes:bytes length: separatorOffset encoding:encoding];
	HTTPLogVerbose(@"BY_MultipartFormDataParser: Processing  header field '%@' : '%@'",name,value);
	// skipe the separator and the next ' ' symbol
	bytes += separatorOffset + 2;
	length -= separatorOffset + 2;

	// parse the "params" part of the header
	if( ![self parseHeaderValueBytes:bytes length:length encoding:encoding] ) {
		NSString* paramsStr = [[NSString alloc] initWithBytes:bytes length:length encoding:NSASCIIStringEncoding];
		HTTPLogError(@"BY_MultipartFormDataParser: Bad params for header with name '%@' and value '%@'",name,value);
		HTTPLogError(@"BY_MultipartFormDataParser: Params str: %@",paramsStr);

		return nil;		
	}
	return self;
}

-(BOOL) parseHeaderValueBytes:(char*) bytes length:(NSUInteger) length encoding:(NSStringEncoding) encoding {
	int offset = 0;
	NSString* currentParam = nil;
	BOOL insideQuote = NO;
	while( offset < length ) {
		if( bytes[offset] == '\"' ) {
			if( !offset || bytes[offset-1] != '\\' ) {
			   insideQuote = !insideQuote;
			}
		}

		// skip quoted symbols
		if( insideQuote ) {
			++ offset;
			continue; 
		}
		if( bytes[offset] == '=' ) {
			if( currentParam ) {
				// found '=' before terminating previous param.
				return NO;
			}
			currentParam = [[NSString alloc] initWithBytes:bytes length:offset encoding:NSASCIIStringEncoding];

			bytes+=offset + 1;
			length -= offset + 1;
			offset = 0;
			continue;
		}
		if( bytes[offset] == ';' ) {
			if( !currentParam ) {
				// found ; before stating '='.
				HTTPLogError(@"BY_MultipartFormDataParser: Unexpected ';' when parsing header");
				return NO;
			}
			NSString* paramValue = by_extractParamValue(bytes, offset,encoding);
			 if( nil == paramValue ) {
				HTTPLogWarn(@"BY_MultipartFormDataParser: Failed to exctract paramValue for key %@ in header %@",currentParam,name);
			}
			else {
#ifdef DEBUG
				if( [params objectForKey:currentParam] ) {
					HTTPLogWarn(@"BY_MultipartFormDataParser: param %@ mentioned more then once in header %@",currentParam,name);
				}
#endif
				[params setObject:paramValue forKey:currentParam];
				HTTPLogVerbose(@"BY_MultipartFormDataParser: header param: %@ = %@",currentParam,paramValue);
			}

			currentParam = nil;

			// ';' separator has ' ' following, skip them.
			bytes+=offset + 2;
			length -= offset + 2;
			offset = 0;
		}
		++ offset;
	}

	// add last param
	if( insideQuote ) {
		HTTPLogWarn(@"BY_MultipartFormDataParser: unterminated quote in header %@",name);
//		return YES;
	}
	if( currentParam ) {
		NSString* paramValue = by_extractParamValue(bytes, length, encoding);

		if( nil == paramValue ) {
			HTTPLogError(@"BY_MultipartFormDataParser: Failed to exctract paramValue for key %@ in header %@",currentParam,name);
		}

#ifdef DEBUG
		if( [params objectForKey:currentParam] ) {
			HTTPLogWarn(@"BY_MultipartFormDataParser: param %@ mentioned more then once in one header",currentParam);
		}
#endif
		[params setObject:paramValue forKey:currentParam];
		HTTPLogVerbose(@"BY_MultipartFormDataParser: header param: %@ = %@",currentParam,paramValue);
		currentParam = nil;
	}
	
	return YES;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@:%@\n params: %@",name,value,params];
}

@end

int by_findChar(const char* str, NSUInteger length, char c) {
	int offset = 0;
	while( offset < length ) {
		if( str[offset] == c )
			return offset;
		++ offset;
	}
	return -1;
}

NSString* by_extractParamValue(const char* bytes, NSUInteger length, NSStringEncoding encoding) {
	if( !length ) 
		return nil;
	NSMutableString* value = nil;
	
	if( bytes[0] == '"' ) {
		// values may be quoted. Strip the quotes to get what we need.
		value = [[NSMutableString alloc] initWithBytes:bytes + 1 length: length - 2 encoding:encoding]; 
	}
	else {
		value = [[NSMutableString alloc] initWithBytes:bytes length: length encoding:encoding];
	}
	// restore escaped symbols
	NSRange range= [value rangeOfString:@"\\"];
	while ( range.length ) {
		[value deleteCharactersInRange:range];
		range.location ++;
		range = [value rangeOfString:@"\\" options:NSLiteralSearch range: range];
	}
	return value;
}

