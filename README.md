# JWURLConnection
***An extension on NSURLConnection with upload possibilities, blocks and delegate protocol***

This class implements a rich delegate protocol, blocks and selectory.
It also provides a POST data upload capability and a connection queue class.

`JWURLConnection` comes along with `JWByteWrite` and `JWByteReader` classes which will be passed to the delegate for easy progress calculations.

## Demo
I'll try to provide an example app in the next weeks, since I don't have much time yet.

## Installation
Easily drop the four files into your project and `#include "JWURLConnection.h`

## Example Usage
``` objective-c
// Easy Block callbacks
- (void)startEasyBlockConnection {
	JWURLConnection *conn = [JWURLConnection connectionWithRequest:req delegate:nil];
	
	[conn setReceivedResponse:^(JWURLConnection *con, NSHTTPURLResponse *resp) {
		[output setText:[NSString stringWithFormat:@"%@\ndid receive response: %@", [output text], [resp allHeaderFields]]];
	}];
	
	[conn setSentBytes:^(JWURLConnection *con, JWByteWriter *bw) {
		NSLog(@"%@\ndid write %i bytes", [output text], [bw bytesWritten]);
	}];
	
	[conn setFinished:^(JWURLConnection *con, NSData *da) {
		NSLog(@"%@\ndid finish: %@", [output text], [[NSString alloc] initWithData:da encoding:NSUTF8StringEncoding]);
	}];
	
	[conn setFailed:^(JWURLConnection *con, NSError *err) {
		NSLog(@"%@\ndid fail: %@", [output text], [err description]);
	}];
	
	[conn start];
}

// Queueing
- (void)startQueuedConnections {
	JWURLConnection *imageConnection = [JWURLConnection connectionByFormUploadingData:[NSData dataWithContentsOfFile:[NSBundle pathToResource:@"image" ofType:@"jpg" inDirectory:imgDir]]];
	JWURLConnection *soundConnection = [JWURLConnection connectionByFormUploadingData:[NSData dataWithContentsOfFile:[NSBundle pathToResource:@"voices" ofType:@"mp3W inDirectory:soundDir]]];
	
	JWURLConnectionQueue *connQueue = [JWURLConnectionQueue queueWithURLConnections:@[imageConnection, soundConnection]];
	[connQueue setDidSendBytesSelector:@selector(queueDidSendBytes:)];
	[connQueue setDelegate:self];
	[connQueue startQueue];
}
- (void)queueDidSendBytes:(JWByteWriter *)br {
	NSLog(@"did write %i if%ibytes", [br totalBytesWritten], [br totalBytesExpectedToWrite]);
}
```

## Credits
Inspired by ASIHTTPRequest and many others
`JWURLConnection` was originally created for http://www.csundm.com


## Contact / Reference
Julian Weinert

- https://github.com/julian-weinert
- https://stackoverflow.com/users/1041122/julian

## License
`JWURLConnection` is available under the GPL V2 license. See the LICENSE file for more info.
