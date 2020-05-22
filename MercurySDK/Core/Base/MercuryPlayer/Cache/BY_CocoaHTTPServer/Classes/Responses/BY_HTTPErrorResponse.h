#import "BY_HTTPResponse.h"

@interface BY_HTTPErrorResponse : NSObject <BY_HTTPResponse> {
    NSInteger _status;
}

- (id)initWithErrorCode:(int)httpErrorCode;

@end
