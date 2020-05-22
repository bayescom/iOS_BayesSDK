#import <Foundation/Foundation.h>
#import "BY_HTTPResponse.h"

@class BY_HTTPConnection;


@interface BY_HTTPFileResponse : NSObject <BY_HTTPResponse>
{
	BY_HTTPConnection *connection;
	
	NSString *filePath;
	UInt64 fileLength;
	UInt64 fileOffset;
	
	BOOL aborted;
	
	int fileFD;
	void *buffer;
	NSUInteger bufferSize;
}

- (id)initWithFilePath:(NSString *)filePath forConnection:(BY_HTTPConnection *)connection;
- (NSString *)filePath;

@end
