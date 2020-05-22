#import <Foundation/Foundation.h>
#import "BY_HTTPResponse.h"


@interface BY_HTTPDataResponse : NSObject <BY_HTTPResponse>
{
	NSUInteger offset;
	NSData *data;
}

- (id)initWithData:(NSData *)data;

@end
