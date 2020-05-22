#import <Foundation/Foundation.h>

@class BY_HTTPMessage;
@class BY_GCDAsyncSocket;


#define BY_WebSocketDidDieNotification  @"BY_WebSocketDidDie"

@interface BY_WebSocket : NSObject
{
	dispatch_queue_t websocketQueue;
	
	BY_HTTPMessage *request;
	BY_GCDAsyncSocket *asyncSocket;
	
	NSData *term;
	
	BOOL isStarted;
	BOOL isOpen;
	BOOL isVersion76;
	
	id __unsafe_unretained delegate;
}

+ (BOOL)isBY_WebSocketRequest:(BY_HTTPMessage *)request;

- (id)initWithRequest:(BY_HTTPMessage *)request socket:(BY_GCDAsyncSocket *)socket;

/**
 * Delegate option.
 * 
 * In most cases it will be easier to subclass BY_WebSocket,
 * but some circumstances may lead one to prefer standard delegate callbacks instead.
**/
@property (/* atomic */ unsafe_unretained) id delegate;

/**
 * The BY_WebSocket class is thread-safe, generally via it's GCD queue.
 * All public API methods are thread-safe,
 * and the subclass API methods are thread-safe as they are all invoked on the same GCD queue.
**/
@property (nonatomic, readonly) dispatch_queue_t websocketQueue;

/**
 * Public API
 * 
 * These methods are automatically called by the BY_HTTPServer.
 * You may invoke the stop method yourself to close the BY_WebSocket manually.
**/
- (void)start;
- (void)stop;

/**
 * Public API
 *
 * Sends a message over the BY_WebSocket.
 * This method is thread-safe.
 **/
- (void)sendMessage:(NSString *)msg;

/**
 * Public API
 *
 * Sends a message over the BY_WebSocket.
 * This method is thread-safe.
 **/
- (void)sendData:(NSData *)msg;

/**
 * Subclass API
 * 
 * These methods are designed to be overriden by subclasses.
**/
- (void)didOpen;
- (void)didReceiveMessage:(NSString *)msg;
- (void)didClose;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * There are two ways to create your own custom BY_WebSocket:
 * 
 * - Subclass it and override the methods you're interested in.
 * - Use traditional delegate paradigm along with your own custom class.
 * 
 * They both exist to allow for maximum flexibility.
 * In most cases it will be easier to subclass BY_WebSocket.
 * However some circumstances may lead one to prefer standard delegate callbacks instead.
 * One such example, you're already subclassing another class, so subclassing BY_WebSocket isn't an option.
**/

@protocol BY_WebSocketDelegate
@optional

- (void)webSocketDidOpen:(BY_WebSocket *)ws;

- (void)webSocket:(BY_WebSocket *)ws didReceiveMessage:(NSString *)msg;

- (void)webSocketDidClose:(BY_WebSocket *)ws;

@end
