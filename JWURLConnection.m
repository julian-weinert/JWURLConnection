//
//  JWURLConnection.m
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

static NSMutableArray *trustedHosts;

#import "JWURLConnection.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation JWByteWriter
@end

@implementation JWByteReader
@end

JWHTTPMethod JWHTTPMethodFromNSString(NSString *method) {
	if ([[method lowercaseString] isEqualToString:@"get"]) {
		return JWHTTPget;
	}
	else if ([[method lowercaseString] isEqualToString:@"post"]) {
		return JWHTTPpost;
	}
	else if ([[method lowercaseString] isEqualToString:@"head"]) {
		return JWHTTPhead;
	}
	else if ([[method lowercaseString] isEqualToString:@"put"]) {
		return JWHTTPput;
	}
	else if ([[method lowercaseString] isEqualToString:@"delete"]) {
		return JWHTTPdelete;
	}
	else if ([[method lowercaseString] isEqualToString:@"connect"]) {
		return JWHTTPconnect;
	}
	else if ([[method lowercaseString] isEqualToString:@"options"]) {
		return JWHTTPoptions;
	}
	else if ([[method lowercaseString] isEqualToString:@"trace"]) {
		return JWHTTPtrace;
	}
	else {
		return -1;
	}
}

NSString *NSStringFromJWHTTPMethod(JWHTTPMethod method) {
	switch (method) {
		case JWHTTPget:
			return @"GET";
			break;
		case JWHTTPpost:
			return @"POST";
			break;
		case JWHTTPhead:
			return @"HEAD";
			break;
		case JWHTTPput:
			return @"PUT";
			break;
		case JWHTTPdelete:
			return @"DELETE";
			break;
		case JWHTTPconnect:
			return @"CONNECT";
			break;
		case JWHTTPoptions:
			return @"OPTIONS";
			break;
		case JWHTTPtrace:
			return @"TRACE";
			break;
		default:
			return nil;
			break;
	}
}

#pragma mark - JWURLConnection

@interface JWURLConnection ()
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskID;
@end

@implementation JWURLConnection

#pragma mark CLASS METHODS

+ (JWURLConnection *)connection {
	return [[self alloc] init];
}

+ (JWURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate {
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

#pragma mark JWHTTPMethod Requests

+ (JWURLConnection *)connectionWithURL:(NSURL *)url HTTPMethod:(JWHTTPMethod)method delegate:(id)delegate {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:NSStringFromJWHTTPMethod(method)];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionWithURL:(NSURL *)url HTTPMethod:(JWHTTPMethod)method delegate:(id)delegate startImmediately:(BOOL)startImmediately {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:NSStringFromJWHTTPMethod(method)];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

+ (JWURLConnection *)connectionWithURL:(NSURL *)url HTTPMethod:(JWHTTPMethod)method usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id)delegate {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:timeOut];
	[request setHTTPMethod:NSStringFromJWHTTPMethod(method)];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionWithURL:(NSURL *)url HTTPMethod:(JWHTTPMethod)method usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id)delegate startImmediately:(BOOL)startImmediately {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:timeOut];
	[request setHTTPMethod:NSStringFromJWHTTPMethod(method)];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

#pragma mark GET Requests

+ (JWURLConnection *)connectionWithGETRequestToURL:(NSURL *)url delegate:(id)delegate {
	return [[self alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionWithGETRequestToURL:(NSURL *)url delegate:(id)delegate startImmediately:(BOOL)startImmediately {
	return [[self alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:delegate startImmediately:startImmediately];
}

+ (JWURLConnection *)connectionWithGETRequestToURL:(NSURL *)url usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id)delegate {
	return [[self alloc] initWithRequest:[NSURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:timeOut] delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionWithGETRequestToURL:(NSURL *)url usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id)delegate startImmediately:(BOOL)startImmediately {
	return [[self alloc] initWithRequest:[NSURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:timeOut] delegate:delegate startImmediately:startImmediately];
}

#pragma mark POST Requests

+ (JWURLConnection *)connectionWithPOSTRequestToURL:(NSURL *)url POSTData:(NSDictionary *)postData delegate:(id)delegate {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *POSTDATA = [NSMutableData data];
	
	for (int i = 0; i < [[postData allKeys] count]; i++) {
		NSString *value;
		
		if ([[[postData allValues] objectAtIndex:i] isKindOfClass:[NSString class]]) {
			value = [[postData allValues] objectAtIndex:i];
		}
		else if ([[[postData allValues] objectAtIndex:i] isKindOfClass:[NSArray class]]) {
			value = [[[postData allValues] objectAtIndex:i] componentsJoinedByString:@","];
		}
		else if ([[[postData allValues] objectAtIndex:i] respondsToSelector:@selector(stringValue)]) {
			value = [[[postData allValues] objectAtIndex:i] stringValue];
		}
		else {
			value = [NSString stringWithFormat:@"%@", [[postData allValues] objectAtIndex:i]];
		}
		
		[POSTDATA appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [[postData allKeys] objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[request setHTTPBody:POSTDATA];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionWithPOSTRequestToURL:(NSURL *)url POSTData:(NSDictionary *)postData delegate:(id)delegate statImmediately:(BOOL)startImmediately {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *POSTDATA = [NSMutableData data];
	
	for (int i = 0; i < [[postData allKeys] count]; i++) {
		NSString *value;
		
		if ([[[postData allValues] objectAtIndex:i] isKindOfClass:[NSString class]]) {
			value = [[postData allValues] objectAtIndex:i];
		}
		else if ([[[postData allValues] objectAtIndex:i] isKindOfClass:[NSArray class]]) {
			value = [[[postData allValues] objectAtIndex:i] componentsJoinedByString:@","];
		}
		else if ([[[postData allValues] objectAtIndex:i] respondsToSelector:@selector(stringValue)]) {
			value = [[[postData allValues] objectAtIndex:i] stringValue];
		}
		else {
			value = [NSString stringWithFormat:@"%@", [[postData allValues] objectAtIndex:i]];
		}
		
		[POSTDATA appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [[postData allKeys] objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[request setHTTPBody:POSTDATA];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

+ (JWURLConnection *)connectionWithPOSTRequestToURL:(NSURL *)url POSTData:(NSDictionary *)postData usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id)delegate {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:timeOut];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *POSTDATA = [NSMutableData data];
	
	for (int i = 0; i < [[postData allKeys] count]; i++) {
		NSString *value;
		
		if ([[[postData allValues] objectAtIndex:i] isKindOfClass:[NSString class]]) {
			value = [[postData allValues] objectAtIndex:i];
		}
		else if ([[[postData allValues] objectAtIndex:i] isKindOfClass:[NSArray class]] || [[[postData allValues] objectAtIndex:i] isKindOfClass:[NSMutableArray class]]) {
			value = [[[postData allValues] objectAtIndex:i] componentsJoinedByString:@","];
		}
		else if ([[[postData allValues] objectAtIndex:i] respondsToSelector:@selector(stringValue)]) {
			value = [[[postData allValues] objectAtIndex:i] stringValue];
		}
		else {
			value = [NSString stringWithFormat:@"%@", [[postData allValues] objectAtIndex:i]];
		}
		
		[POSTDATA appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [[postData allKeys] objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[request setHTTPBody:POSTDATA];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionWithPOSTRequestToURL:(NSURL *)url POSTData:(NSDictionary *)postData usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id)delegate startImmediately:(BOOL)startImmediately {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:timeOut];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *POSTDATA = [NSMutableData data];
	
	for (int i = 0; i < [[postData allKeys] count]; i++) {
		NSString *value;
		
		if ([[[postData allValues] objectAtIndex:i] isKindOfClass:[NSString class]]) {
			value = [[postData allValues] objectAtIndex:i];
		}
		else if ([[[postData allValues] objectAtIndex:i] isKindOfClass:[NSArray class]]) {
			value = [[[postData allValues] objectAtIndex:i] componentsJoinedByString:@","];
		}
		else if ([[[postData allValues] objectAtIndex:i] respondsToSelector:@selector(stringValue)]) {
			value = [[[postData allValues] objectAtIndex:i] stringValue];
		}
		else {
			value = [NSString stringWithFormat:@"%@", [[postData allValues] objectAtIndex:i]];
		}
		
		[POSTDATA appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [[postData allKeys] objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
		[POSTDATA appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[request setHTTPBody:POSTDATA];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

#pragma mark Form uploading data

+ (JWURLConnection *)connectionByFormUploadingData:(NSData *)data toURL:(NSURL *)url withFileName:(NSString *)fileName forFieldName:(NSString *)fieldName delegate:(id)delegate {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postData = [[NSMutableData alloc] initWithData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", fieldName, fileName ?: @"empty_file_name"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:data];
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:postData];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionByFormUploadingData:(NSData *)data toURL:(NSURL *)url withFileName:(NSString *)fileName forFieldName:(NSString *)fieldName withAdditionalPOSTData:(NSDictionary *)POSTdata delegate:(id)delegate {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postData = [[NSMutableData alloc] init];
	
	[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, fileName ?: @"empty_file_name"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:data];
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	for (int i = 0; i < [[POSTdata allKeys] count]; i++) {
		NSString *value;
		
		if ([[[POSTdata allValues] objectAtIndex:i] isKindOfClass:[NSString class]]) {
			value = [[POSTdata allValues] objectAtIndex:i];
		}
		else if ([[[POSTdata allValues] objectAtIndex:i] isKindOfClass:[NSArray class]]) {
			value = [[[POSTdata allValues] objectAtIndex:i] componentsJoinedByString:@","];
		}
		else if ([[[POSTdata allValues] objectAtIndex:i] respondsToSelector:@selector(stringValue)]) {
			value = [[[POSTdata allValues] objectAtIndex:i] stringValue];
		}
		else {
			value = [NSString stringWithFormat:@"%@", [[POSTdata allValues] objectAtIndex:i]];
		}
		
		[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [[POSTdata allKeys] objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[request setHTTPBody:postData];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionByFormUploadingData:(NSData *)data toURL:(NSURL *)url withFileName:(NSString *)fileName forFieldName:(NSString *)fieldName usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut delegate:(id)delegate {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:timeOut];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postData = [[NSMutableData alloc] initWithData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", fieldName, fileName ?: @"empty_file_name"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:data];
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:postData];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionByFormUploadingData:(NSData *)data toURL:(NSURL *)url withFileName:(NSString *)fileName forFieldName:(NSString *)fieldName usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut withAdditionalPOSTData:(NSDictionary *)POSTdata delegate:(id)delegate {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:timeOut];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postData = [[NSMutableData alloc] initWithData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, fileName ?: @"empty_file_name"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:data];
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	for (int i = 0; i < [[POSTdata allKeys] count]; i++) {
		NSString *value;
		
		if ([[[POSTdata allValues] objectAtIndex:i] isKindOfClass:[NSString class]]) {
			value = [[POSTdata allValues] objectAtIndex:i];
		}
		else if ([[[POSTdata allValues] objectAtIndex:i] isKindOfClass:[NSArray class]]) {
			value = [[[POSTdata allValues] objectAtIndex:i] componentsJoinedByString:@","];
		}
		else if ([[[POSTdata allValues] objectAtIndex:i] respondsToSelector:@selector(stringValue)]) {
			value = [[[POSTdata allValues] objectAtIndex:i] stringValue];
		}
		else {
			value = [NSString stringWithFormat:@"%@", [[POSTdata allValues] objectAtIndex:i]];
		}
		
		[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [[POSTdata allKeys] objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[request setHTTPBody:postData];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:NO];
}

+ (JWURLConnection *)connectionByFormUploadingData:(NSData *)data toURL:(NSURL *)url withFileName:(NSString *)fileName forFieldName:(NSString *)fieldName usingCachePolicy:(NSURLRequestCachePolicy)cachePolicy andTimeout:(NSTimeInterval)timeOut withAdditionalPOSTData:(NSDictionary *)POSTdata delegate:(id<JWURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:timeOut];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postData = [[NSMutableData alloc] initWithData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, fileName ?: @"empty_file_name"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:data];
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	for (int i = 0; i < [[POSTdata allKeys] count]; i++) {
		NSString *value;
		
		if ([[[POSTdata allValues] objectAtIndex:i] isKindOfClass:[NSString class]]) {
			value = [[POSTdata allValues] objectAtIndex:i];
		}
		else if ([[[POSTdata allValues] objectAtIndex:i] isKindOfClass:[NSArray class]]) {
			value = [[[POSTdata allValues] objectAtIndex:i] componentsJoinedByString:@","];
		}
		else if ([[[POSTdata allValues] objectAtIndex:i] respondsToSelector:@selector(stringValue)]) {
			value = [[[POSTdata allValues] objectAtIndex:i] stringValue];
		}
		else {
			value = [NSString stringWithFormat:@"%@", [[POSTdata allValues] objectAtIndex:i]];
		}
		
		[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [[POSTdata allKeys] objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[request setHTTPBody:postData];
	
	return [[self alloc] initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

#pragma mark INSTANCE METHODS

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
	self = [super initWithRequest:request delegate:self];
	if (self) {
		_delegate = delegate;
		_defaultStringEncoding = NSUTF8StringEncoding;
		_bodySize = [[request HTTPBody] length];
	}
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
	self = [super initWithRequest:request delegate:self startImmediately:startImmediately];
	if (self) {
		_delegate = delegate;
		_defaultStringEncoding = NSUTF8StringEncoding;
		_bodySize = [[request HTTPBody] length];
	}
	return self;
}

- (NSData *)getDataSynchronously {
	return [self getDataSynchronouslyReturningResponse:nil error:nil];
}

- (NSData *)getDataSynchronouslyReturningResponse:(NSHTTPURLResponse *__autoreleasing *)response error:(NSError *__autoreleasing *)error {
	return [JWURLConnection sendSynchronousRequest:[self originalRequest] returningResponse:response error:error];
}

- (void)addTrustedHost:(NSString *)host {
	if (!trustedHosts) {
		trustedHosts = [NSMutableArray array];
	}
	
	[trustedHosts addObject:host];
}

- (void)removeTrustedHost:(NSString *)host {
	[trustedHosts removeObject:host];
}

- (void)setTrustedHosts:(NSArray *)hosts {
	trustedHosts = [NSMutableArray arrayWithArray:hosts];
}

- (void)start {
	__block NSNumber *count = [NSNumber numberWithInt:[[[[NSThread currentThread] threadDictionary] objectForKey:@"count"] integerValue] + 1 ];
	[NSThread detachNewThreadBlock:^{
		[[[NSThread currentThread] threadDictionary] setObject:count forKey:@"count"];
		_backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
			[self cancel];
		}];
		
		[super start];
		
		if ([(NSNumber *)[[[NSThread currentThread] threadDictionary] objectForKey:@"count"] isEqual:@1]) {
			CFRunLoopRun();
		}
	}];
}

- (void)cancel {
	[super cancel];
	
	if (([(NSNumber *)[[[NSThread currentThread] threadDictionary] objectForKey:@"count"] isEqual:@1])) {
		CFRunLoopStop(CFRunLoopGetCurrent());
	}
}

- (CGFloat)percentageLoaded {
	return (100 / _expectedContentLength) * currentContentLength;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	return [super methodSignatureForSelector:aSelector];
}

#pragma mark PROTOCOL

- (void)connection:(JWURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([_delegate respondsToSelector:_willSendRequestForAuthenticationChallengeSelector]) {
		[_delegate performSelector:_willSendRequestForAuthenticationChallengeSelector withObject:connection withObject:challenge];
	}
	else if ([_delegate respondsToSelector:@selector(URLconnection:willSendRequestForAuthenticationChallenge:)]) {
		[_delegate URLconnection:connection willSendRequestForAuthenticationChallenge:challenge];
	}
	else if (_willSendRequestForAuthenticationChallenge) {
		_willSendRequestForAuthenticationChallenge(challenge);
	}
	else {
		[[challenge sender] performDefaultHandlingForAuthenticationChallenge:challenge];
	}
}

- (void)connection:(JWURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	_responseData = [[NSMutableData alloc] init];
	_statusCode = [(NSHTTPURLResponse *)response statusCode];
	_expectedContentLength = (NSInteger)[response expectedContentLength];
	
	NSString *stringEncodingName = [response textEncodingName];
	
	if (stringEncodingName) {
		_encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]));
	}
	else {
		_encoding = _defaultStringEncoding;
	}
	
	if ([_delegate respondsToSelector:_didReceiveResponseSelector]) {
		objc_msgSend(_delegate, _didReceiveResponseSelector, connection, response);
	}
	
	if ([_delegate respondsToSelector:@selector(URLConnection:didReceiveResponse:)]) {
		[_delegate performSelector:@selector(URLConnection:didReceiveResponse:) withObject:connection withObject:(NSHTTPURLResponse *)response];
	}
	
	if ([_queue respondsToSelector:@selector(URLConnection:didReceiveResponse:)]) {
		[_queue performSelector:@selector(URLConnection:didReceiveResponse:) withObject:connection withObject:(NSHTTPURLResponse *)response];
	}
	
	if (_receivedResponse) {
		_receivedResponse((NSHTTPURLResponse *)response);
	}
}

- (void)connection:(JWURLConnection *)connection didReceiveData:(NSData *)data {
	[_responseData appendData:data];
	currentContentLength = currentContentLength + [data length];
	
	JWByteReader *byteReader = [[JWByteReader alloc] init];
	byteReader.bytesRead = [data length];
	byteReader.totalBytesRead = currentContentLength;
	byteReader.totalBytesExpectedToWrite = _expectedContentLength;
	
	
	if ([_delegate respondsToSelector:_didReceiveDataSelector]) {
		objc_msgSend(_delegate, _didReceiveBytesSelector, connection, data);
	}
	
	if ([_delegate respondsToSelector:_didReceiveBytesSelector]) {
		objc_msgSend(_delegate, _didReceiveBytesSelector, connection, byteReader);
	}
	
	if ([_delegate respondsToSelector:@selector(connection:didReceiveData:)]) {
		[_delegate performSelector:@selector(connection:didReceiveData:) withObject:connection withObject:data];
	}
	if ([_delegate respondsToSelector:@selector(URLConnection:didReveiveBytes:)]) {
		[_delegate performSelector:@selector(URLConnection:didReveiveBytes:) withObject:connection withObject:byteReader];
	}
	
	if ([_queue respondsToSelector:@selector(connection:didReceiveData:)]) {
		[_queue performSelector:@selector(connection:didReceiveData:) withObject:connection withObject:data];
	}
	if ([_queue respondsToSelector:@selector(URLConnection:didReveiveBytes:)]) {
		[_queue performSelector:@selector(URLConnection:didReveiveBytes:) withObject:connection withObject:byteReader];
	}
	
	if (_receivedData) {
		_receivedData(data);
	}
	if (_receivedBytes) {
		_receivedBytes(byteReader);
	}
}

- (void)connection:(JWURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	JWByteWriter *byteWriter = [[JWByteWriter alloc] init];
	byteWriter.bytesWritten = bytesWritten;
	byteWriter.totalBytesWritten = totalBytesWritten;
	byteWriter.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
	
	if ([_delegate respondsToSelector:_didSendBytesSelector]) {
		objc_msgSend(_delegate, _didSendBytesSelector, connection, byteWriter);
	}
	
	if ([_delegate respondsToSelector:@selector(URLConnection:didSendBytes:)]) {
		[_delegate performSelector:@selector(URLConnection:didSendBytes:) withObject:connection withObject:byteWriter];
	}
	
	if ([_queue respondsToSelector:@selector(URLConnection:didSendBytes:)]) {
		[_queue performSelector:@selector(URLConnection:didSendBytes:) withObject:connection withObject:byteWriter];
	}
	
	if (_sentBytes) {
		_sentBytes(byteWriter);
	}
}

- (void)connectionDidFinishLoading:(JWURLConnection *)connection {
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([_delegate respondsToSelector:_didFinishSelector]) {
			objc_msgSend(_delegate, _didFinishSelector, connection);
		}
		if ([_delegate respondsToSelector:_didFinishLoadingSelector]) {
			objc_msgSend(_delegate, _didFinishLoadingSelector, connection, [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding]);
		}
		if ([_delegate respondsToSelector:_didFinishLoadingDataSelector]) {
			objc_msgSend(_delegate, _didFinishLoadingDataSelector, connection, _responseData);
		}
		
		if ([_delegate respondsToSelector:@selector(URLConnectionDidFinish:)]) {
			[_delegate URLConnectionDidFinish:connection];
		}
		if ([_delegate respondsToSelector:@selector(URLConnection:didFinishLoading:)]) {
			[_delegate URLConnection:connection didFinishLoading:[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding]];
		}
		if ([_delegate respondsToSelector:@selector(URLConnection:didFinishLoadingData:withEncoding:)]) {
			[_delegate URLConnection:connection didFinishLoadingData:_responseData withEncoding:_encoding];
		}
		
		if ([_queue respondsToSelector:@selector(URLConnectionDidFinish:)]) {
			[_queue performSelector:@selector(URLConnectionDidFinish:) withObject:connection ];
		}
		if ([_queue respondsToSelector:@selector(URLConnection:didFinishLoading:)]) {
			[_queue performSelector:@selector(URLConnection:didFinishLoading:) withObject:connection withObject:[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding]];
		}
		if ([_queue respondsToSelector:@selector(URLConnection:didFinishLoadingData:)]) {
			[_queue performSelector:@selector(URLConnection:didFinishLoadingData:) withObject:connection withObject:_responseData];
		}
		
		if (_finished) {
			_finished(_responseData, _encoding);
		}
		
		_responseData = nil;
		
		if (([(NSNumber *)[[[NSThread currentThread] threadDictionary] objectForKey:@"count"] isEqual:@1])) {
			CFRunLoopStop(CFRunLoopGetCurrent());
		}
		
		[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskID];
	});
}

- (void)connection:(JWURLConnection *)connection didFailWithError:(NSError *)error {
	if ([_delegate respondsToSelector:_didFailSelector]) {
		objc_msgSend(_delegate, _didFailSelector, connection, error);
	}
	
	if ([_delegate respondsToSelector:@selector(URLConnection:didFailWithError:)]) {
		[_delegate URLConnection:connection didFailWithError:error];
	}
	
	if ([_queue respondsToSelector:@selector(URLConnection:didFailWithError:)]) {
		[_queue performSelector:@selector(URLConnection:didFailWithError:) withObject:connection withObject:error];
	}
	
	if (_failed) {
		_failed(error);
	}
	
	_responseData = nil;
	
	[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskID];
	if (([(NSNumber *)[[[NSThread currentThread] threadDictionary] objectForKey:@"count"] isEqual:@1])) {
		CFRunLoopStop(CFRunLoopGetCurrent());
	}
}

- (NSCachedURLResponse *)connection:(JWURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	if (_willCacheResponseSelector && [_delegate respondsToSelector:_willCacheResponseSelector]) {
		if (objc_msgSend(_delegate, _willCacheResponseSelector, connection, cachedResponse)) {
			return cachedResponse;
		}
	}
	else if (_willCacheResponse) {
		if (_willCacheResponse(connection, cachedResponse)) {
			return cachedResponse;
		}
	}
	else if (_useCache) {
		return cachedResponse;
	}
	else if ([_delegate respondsToSelector:@selector(URLConnection:willCacheResponse:)]) {
		if ([_delegate URLConnection:connection willCacheResponse:cachedResponse]) {
			return cachedResponse;
		}
	}
	
	return nil;
}

@end


#pragma mark JWURLConnectionQueue

@interface JWURLConnectionQueue ()
@property (atomic, assign) BOOL currentlySending;
@end


@implementation JWURLConnectionQueue

+ (id)queue {
	return [[self alloc] init];
}

+ (id)queueWithDelegate:(id)delegate {
	return [[self alloc] initWithDelegate:delegate];
}

+ (id)queueWithURLConnections:(NSArray *)connections {
	return [[self alloc] initWithURLConnections:connections];
}

#pragma mark INSTANCE METHODS

- (id)init {
	self = [super init];
	if (self) {
		_totalBytesToSend = 0;
		_currentlySending = NO;
		mainQueue = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithDelegate:(id)delegate {
	self = [super init];
	if (self) {
		_delegate = delegate;
		_totalBytesToSend = 0;
		_currentlySending = NO;
		mainQueue = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithURLConnections:(NSArray *)connections {
	self = [super init];
	if (self) {
		_totalBytesToSend = 0;
		_currentlySending = NO;
		mainQueue = [NSMutableArray arrayWithArray:connections];
	}
	return self;
}

- (void)addToQueue:(JWURLConnection *)connection {
	[mainQueue addObject:connection];
	_totalBytesToSend = _totalBytesToSend + [[[connection originalRequest] HTTPBody] length];
}

- (void)removeFromQueue:(JWURLConnection *)connection {
	if ([mainQueue indexOfObject:connection] < currentIndex) {
		currentIndex--;
	}
	else if ([mainQueue indexOfObject:connection] == currentIndex) {
		return;
	}
	
	[mainQueue removeObject:connection];
	_totalBytesToSend = _totalBytesToSend - [[[connection originalRequest] HTTPBody] length];
}

- (void)startQueue {
	if (_currentlySending) {
		return;
	}
	currentIndex = -1;
	
	bytesReceived = 0;
	bytesReceived = 0;
	
	if (!mainQueue || [mainQueue isEqual:@[]]) {
		return;
	}
	
	[self next];
}

- (void)next {
	if (_currentlySending) {
		return;
	}
	
	currentIndex++;
	
	if (currentIndex < [mainQueue count]) {
		JWURLConnection *con = [mainQueue objectAtIndex:currentIndex];
		[con setQueue:self];
		_currentlySending = YES;
		[con start];
	}
	else {
		if ([_delegate respondsToSelector:_didFinishSelector]) {
			[_delegate performSelector:_didFinishSelector];
		}
		if (_finished) {
			_finished();
		}
	}
}

#pragma mark PROTOCOL

- (void)URLConnection:(JWURLConnection *)connection didSendBytes:(JWByteWriter *)byteWriter {
	bytesSent = bytesSent + byteWriter.bytesWritten;
	
	JWByteWriter *writer = [[JWByteWriter alloc] init];
	writer.bytesWritten = byteWriter.bytesWritten;
	writer.totalBytesWritten = bytesSent;
	writer.totalBytesExpectedToWrite = _totalBytesToSend;
	
	if ([_delegate respondsToSelector:_didSendBytesSelector]) {
		[_delegate performSelector:_didSendBytesSelector withObject:writer];
	}
	if (_sentBytes) {
		_sentBytes(connection, writer);
	}
}

- (void)URLConnection:(JWURLConnection *)connection didReveiveBytes:(JWByteReader *)byteReader {
	bytesReceived = bytesReceived + byteReader.bytesRead;
	
	JWByteReader *reader = [[JWByteReader alloc] init];
	reader.bytesRead = byteReader.bytesRead;
	reader.totalBytesRead = bytesReceived;
	
	if ([_delegate respondsToSelector:_didReceiveBytesSelector]) {
		[_delegate performSelector:_didReceiveBytesSelector withObject:reader];
	}
	if (_receivedBytes) {
		_receivedBytes(connection, reader);
	}
}

- (void)URLConnectionDidFinish:(JWURLConnection *)connection {
	_currentlySending = NO;
	[self next];
	[self removeFromQueue:connection];
}

- (void)URLConnection:(JWURLConnection *)connection didFailWithError:(NSError *)error {
	_currentlySending = NO;
	[self next];
}

@end

#pragma mark -
#pragma mark Foundation categories

@implementation NSURL (appendQueryString)
- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    return [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString], [self query] ? @"&" : @"?", queryString]];
}
@end
