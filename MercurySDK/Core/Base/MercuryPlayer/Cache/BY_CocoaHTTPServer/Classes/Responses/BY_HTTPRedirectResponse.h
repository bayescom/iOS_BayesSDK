#import <Foundation/Foundation.h>
#import "BY_HTTPResponse.h"


@interface BY_HTTPRedirectResponse : NSObject <BY_HTTPResponse>
{
	NSString *redirectPath;
}

- (id)initWithPath:(NSString *)redirectPath;

@end
