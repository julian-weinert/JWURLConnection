//
//  JWURLConnection.h
//
//  Created by Julian Weinert on 07.01.13.
//  Copyright (c) 2013 Julian Weinert.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "NSThread+blocks.h"

typedef NS_ENUM(NSUInteger, JWHTTPMethod) {
	JWHTTPget,
	JWHTTPpost,
	JWHTTPhead,
	JWHTTPput,
	JWHTTPdelete,
	JWHTTPconnect,
	JWHTTPoptions,
	JWHTTPtrace
};

JWHTTPMethod JWHTTPMethodFromNSString(NSString *method);
NSString *NSStringFromJWHTTPMethod(JWHTTPMethod method);

@class JWURLConnectionQueue;

@interface JWByteWriter : NSObject
@property (nonatomic, assign) NSInteger bytesWritten;
@property (nonatomic, assign) NSInteger totalBytesWritten;
@property (nonatomic, assign) NSInteger totalBytesExpectedToWrite;
@end

@interface JWByteReader : NSObject
@property (nonatomic, assign) NSInteger bytesRead;
@property (nonatomic, assign) NSInteger totalBytesRead;
@property (nonatomic, assign) NSInteger totalBytesExpectedToWrite;
@end


@protocol JWURLConnectionDelegate;

#pragma mark - JWURLConnection

@interface JWURLConnection : NSURLConnection <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	NSInteger currentContentLength;
}

@property (nonatomic, assign) id<JWURLConnectionDelegate>delegate;
@property (nonatomic, retain) JWURLConnectionQueue *queue;

@property (nonatomic, assign) NSStringEncoding defaultStringEncoding;
@property (nonatomic, assign) NSInteger expectedContentLength;
@property (nonatomic, assign) NSStringEncoding encoding;
@property (nonatomic, retain) NSDictionary *userInfo;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) NSInteger bodySize;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) BOOL useCache;

#pragma mark SELECTORS

@property (nonatomic, assign) SEL didEnd;

@property (nonatomic, assign) SEL didReceiveResponseSelector;
@property (nonatomic, assign) SEL didReceiveBytesSelector;
@property (nonatomic, assign) SEL didReceiveDataSelector;
@property (nonatomic, assign) SEL didSendBytesSelector;

@property (nonatomic, assign) SEL didFinishSelector;
@property (nonatomic, assign) SEL didFinishLoadingSelector;
@property (nonatomic, assign) SEL didFinishLoadingDataSelector;
@property (nonatomic, assign) SEL didFailSelector;

@property (nonatomic, assign) SEL willSendRequestForAuthenticationChallengeSelector;


@property (nonatomic, assign) SEL didTrustCertificateWithHostSelector;
@property (nonatomic, assign) SEL didAvoidSecurityTrapSelector;

@property (nonatomic, assign) SEL willCacheResponseSelector;

#pragma mark BLOCKS

@property (nonatomic, copy) void (^receivedResponse)(NSHTTPURLResponse *response);
@property (nonatomic, copy) void (^receivedBytes)(JWByteReader *byteReader);
@property (nonatomic, copy) void (^receivedData)(NSData *data);
@property (nonatomic, copy) void (^sentBytes)(JWByteWriter *byteWriter);

@property (nonatomic, copy) void (^finished)(NSData *responseData, NSStringEncoding encoding);
@property (nonatomic, copy) void (^failed)(NSError *error);

@property (nonatomic, copy) void (^willSendRequestForAuthenticationChallenge)(NSURLAuthenticationChallenge *challenge);

@property (nonatomic, copy) void (^trustedCertificateWithHost)(NSString *host, NSURLAuthenticationChallenge *challenge);
@property (nonatomic, copy) void (^avoidedSecurityTrap)(NSURLAuthenticationChallenge *challenge);

@property (nonatomic, copy) BOOL (^willCacheResponse)(JWURLConnection *connection, NSCachedURLResponse *cachedResponse);

#pragma mark CLASS METHODS

+ (JWURLConnection *)connection;

+ (JWURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id<JWURLConnectionDelegate>)delegate;
+ (JWURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id<JWURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately;

#pragma mark JWHTTPMethod Requests

+ (JWURLConnection *)connectionWithURL:(NSURL *)url HTTPMethod:(JWHTTPMethod)method delegate:(id)delegate;
+ (JWURLConnection *)connectionWithURL:(NSURL *)url HTTPMethod:(JWHTTPMethod)method delegate:(id)delegate startImmediately:(BOOL)startImmediately;
+ (JWURLConnection *)connectionWithURL:(NSURL *)url HTTPMethod:(JWHTTPMethod)method usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id<JWURLConnectionDelegate>)delegate;
+ (JWURLConnection *)connectionWithURL:(NSURL *)url HTTPMethod:(JWHTTPMethod)method usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id<JWURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately;

#pragma mark GET Requests

+ (JWURLConnection *)connectionWithGETRequestToURL:(NSURL *)url delegate:(id<JWURLConnectionDelegate>)delegate;
+ (JWURLConnection *)connectionWithGETRequestToURL:(NSURL *)url delegate:(id<JWURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately;
+ (JWURLConnection *)connectionWithGETRequestToURL:(NSURL *)url usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id<JWURLConnectionDelegate>)delegate;
+ (JWURLConnection *)connectionWithGETRequestToURL:(NSURL *)url usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id<JWURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately;

#pragma mark POST Requests

+ (JWURLConnection *)connectionWithPOSTRequestToURL:(NSURL *)url POSTData:(NSDictionary *)postData delegate:(id<JWURLConnectionDelegate>)delegate;
+ (JWURLConnection *)connectionWithPOSTRequestToURL:(NSURL *)url POSTData:(NSDictionary *)postData delegate:(id<JWURLConnectionDelegate>)delegate statImmediately:(BOOL)startImmediately;
+ (JWURLConnection *)connectionWithPOSTRequestToURL:(NSURL *)url POSTData:(NSDictionary *)postData usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id<JWURLConnectionDelegate>)delegate;
+ (JWURLConnection *)connectionWithPOSTRequestToURL:(NSURL *)url POSTData:(NSDictionary *)postData usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id<JWURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately;

#pragma mark Form uploading data

+ (JWURLConnection *)connectionByFormUploadingData:(NSData *)data toURL:(NSURL *)url withFileName:(NSString *)fileName forFieldName:(NSString *)fieldName delegate:(id<JWURLConnectionDelegate>)delegate;
+ (JWURLConnection *)connectionByFormUploadingData:(NSData *)data toURL:(NSURL *)url withFileName:(NSString *)fileName forFieldName:(NSString *)fieldName withAdditionalPOSTData:(NSDictionary *)POSTdata delegate:(id<JWURLConnectionDelegate>)delegate;
+ (JWURLConnection *)connectionByFormUploadingData:(NSData *)data toURL:(NSURL *)url withFileName:(NSString *)fileName forFieldName:(NSString *)fieldName usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id<JWURLConnectionDelegate>)delegate;
+ (JWURLConnection *)connectionByFormUploadingData:(NSData *)data toURL:(NSURL *)url withFileName:(NSString *)fileName forFieldName:(NSString *)fieldName usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut withAdditionalPOSTData:(NSDictionary *)POSTdata delegate:(id<JWURLConnectionDelegate>)delegate;
+ (JWURLConnection *)connectionByFormUploadingData:(NSData *)data toURL:(NSURL *)url withFileName:(NSString *)fileName forFieldName:(NSString *)fieldName usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut withAdditionalPOSTData:(NSDictionary *)POSTdata delegate:(id<JWURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately;

#pragma mark INSTANCE METHODS

- (id)initWithRequest:(NSMutableURLRequest *)request delegate:(id)delegate;
- (id)initWithRequest:(NSMutableURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately;

- (NSData *)getDataSynchronously;
- (NSData *)getDataSynchronouslyReturningResponse:(NSHTTPURLResponse **)response error:(NSError **)error;

- (void)addTrustedHost:(NSString *)host;
- (void)removeTrustedHost:(NSString *)host;
- (void)setTrustedHosts:(NSArray *)hosts;

- (void)start;
- (void)cancel;

- (CGFloat)percentageLoaded;

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;

@end

#pragma mark - JWURLConnectionDelegate

@protocol JWURLConnectionDelegate <NSObject>

@optional
- (void)URLconnection:(JWURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

- (void)URLConnectionDidEnd:(JWURLConnection *)connection;
- (void)URLConnection:(JWURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response;
- (void)URLConnection:(JWURLConnection *)connection didReceiveData:(NSData *)data;
- (void)URLConnection:(JWURLConnection *)connection didReveiveBytes:(JWByteReader *)byteReader;
- (void)URLConnection:(JWURLConnection *)connection didSendBytes:(JWByteWriter *)byteWriter;

- (void)URLConnectionDidFinish:(JWURLConnection *)connection;
- (void)URLConnection:(JWURLConnection *)connection didFinishLoading:(NSString *)responseString;
- (void)URLConnection:(JWURLConnection *)connection didFinishLoadingData:(NSData *)data withEncoding:(NSStringEncoding)encoding;

- (void)URLConnection:(JWURLConnection *)connection didFailWithError:(NSError *)error;

- (void)URLConnection:(JWURLConnection *)connection didTrustCertificateWithHost:(NSString *)host withAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)URLConnection:(JWURLConnection *)connection didAvoidSecurityTrapWithAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

- (BOOL)URLConnection:(JWURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;

@end


#pragma mark - JWURLConnection


@interface JWURLConnectionQueue : NSObject <JWURLConnectionDelegate> {
	NSMutableArray *mainQueue;
	NSInteger currentIndex;
	
	NSInteger bytesSent;
	NSInteger bytesReceived;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) NSInteger totalBytesToSend;

#pragma mark SELECTORS

@property (nonatomic, assign) SEL didFinishSelector;
@property (nonatomic, assign) SEL didSendBytesSelector;
@property (nonatomic, assign) SEL didReceiveBytesSelector;

#pragma mark BLOCKS

@property (nonatomic, copy) void (^finished)(void);
@property (nonatomic, copy) void (^sentBytes)(JWURLConnection *connection, JWByteWriter *byteWriter);
@property (nonatomic, copy) void (^receivedBytes)(JWURLConnection *connection, JWByteReader *byteReader);

#pragma mark CLASS METHODS

+ (id)queue;
+ (id)queueWithDelegate:(id)delegate;
+ (id)queueWithURLConnections:(NSArray *)connections;

#pragma mark INSTANCE METHODS

- (id)init;
- (id)initWithDelegate:(id)delegate;
- (id)initWithURLConnections:(NSArray *)connections;

- (void)addToQueue:(JWURLConnection *)connection;
- (void)removeFromQueue:(JWURLConnection *)connection;
- (void)startQueue;

@end

#pragma mark -
#pragma mark Foundation categories

@interface NSURL (appendQueryString)
- (NSURL *)URLByAppendingQueryString:(NSString *)queryString;
@end
