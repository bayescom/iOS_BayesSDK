#import <Foundation/Foundation.h>

@class BY_GCDAsyncSocket;
@class BY_HTTPMessage;
@class BY_HTTPServer;
@class BY_WebSocket;
@protocol BY_HTTPResponse;


#define HTTPConnectionDidDieNotification  @"HTTPConnectionDidDie"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface BY_HTTPConfig : NSObject
{
	BY_HTTPServer __unsafe_unretained *server;
	NSString __strong *documentRoot;
	dispatch_queue_t queue;
}

- (id)initWithServer:(BY_HTTPServer *)server documentRoot:(NSString *)documentRoot;
- (id)initWithServer:(BY_HTTPServer *)server documentRoot:(NSString *)documentRoot queue:(dispatch_queue_t)q;

@property (nonatomic, unsafe_unretained, readonly) BY_HTTPServer *server;
@property (nonatomic, strong, readonly) NSString *documentRoot;
@property (nonatomic, readonly) dispatch_queue_t queue;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface BY_HTTPConnection : NSObject
{
	dispatch_queue_t connectionQueue;
	BY_GCDAsyncSocket *asyncSocket;
	BY_HTTPConfig *config;
	
	BOOL started;
	
	BY_HTTPMessage *request;
	unsigned int numHeaderLines;
	
	BOOL sentResponseHeaders;
	
	NSString *nonce;
	long lastNC;
	
	NSObject<BY_HTTPResponse> *httpResponse;
	
	NSMutableArray *ranges;
	NSMutableArray *ranges_headers;
	NSString *ranges_boundry;
	int rangeIndex;
	
	UInt64 requestContentLength;
	UInt64 requestContentLengthReceived;
	UInt64 requestChunkSize;
	UInt64 requestChunkSizeReceived;
  
	NSMutableArray *responseDataSizes;
}

- (id)initWithAsyncSocket:(BY_GCDAsyncSocket *)newSocket configuration:(BY_HTTPConfig *)aConfig;

- (void)start;
- (void)stop;

- (void)startConnection;

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path;
- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path;

- (BOOL)isSecureServer;
- (NSArray *)sslIdentityAndCertificates;

- (BOOL)isPasswordProtected:(NSString *)path;
- (BOOL)useDigestAccessAuthentication;
- (NSString *)realm;
- (NSString *)passwordForUser:(NSString *)username;

- (NSDictionary *)parseParams:(NSString *)query;
- (NSDictionary *)parseGetParams;

- (NSString *)requestURI;

- (NSArray *)directoryIndexFileNames;
- (NSString *)filePathForURI:(NSString *)path;
- (NSString *)filePathForURI:(NSString *)path allowDirectory:(BOOL)allowDirectory;
- (NSObject<BY_HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path;
- (BY_WebSocket *)webSocketForURI:(NSString *)path;

- (void)prepareForBodyWithSize:(UInt64)contentLength;
- (void)processBodyData:(NSData *)postDataChunk;
- (void)finishBody;

- (void)handleVersionNotSupported:(NSString *)version;
- (void)handleAuthenticationFailed;
- (void)handleResourceNotFound;
- (void)handleInvalidRequest:(NSData *)data;
- (void)handleUnknownMethod:(NSString *)method;

- (NSData *)preprocessResponse:(BY_HTTPMessage *)response;
- (NSData *)preprocessErrorResponse:(BY_HTTPMessage *)response;

- (void)finishResponse;

- (BOOL)shouldDie;
- (void)die;

@end

@interface BY_HTTPConnection (AsynchronousBY_HTTPResponse)
- (void)responseHasAvailableData:(NSObject<BY_HTTPResponse> *)sender;
- (void)responseDidAbort:(NSObject<BY_HTTPResponse> *)sender;
@end
