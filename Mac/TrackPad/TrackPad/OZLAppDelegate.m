//
//  OZLAppDelegate.m
//  TrackPad
//
//  Created by Lee Zhijie on 9/24/12.
//  Copyright (c) 2012 Lee Zhijie. All rights reserved.
//

#import "OZLAppDelegate.h"
#import <CoreFoundation/CoreFoundation.h>
#import <CFNetwork/CFSocketStream.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <unistd.h>
#import <CFNetwork/CFSocketStream.h>
#import <CFNetwork/CFNetwork.h>

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

@implementation OZLAppDelegate
@synthesize mInfoTextField;
@synthesize mStartServerBtn;
@synthesize mStopServerBtn;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    mTcpPort = 20000;
    mBroadcastPort = mTcpPort +1;
}

- (void) onBroadcastTimer:(NSTimer*)theTimer
{
    [udpSocket enableBroadcast:YES error:nil];
    NSString* msg = @"testing";
	NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
	[udpSocket sendData:data toHost:@"255.255.255.255" port:mBroadcastPort withTimeout:-1 tag:tag++];
    NSLog(@"sending with msg:%@ with :%ld",msg,tag);

}

- (IBAction)onStartSever:(id)sender {
    
    //broadcast && timer to build connection
    udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
	[udpSocket enableBroadcast:YES error:nil];
	NSError *error = nil;
	
	if (![udpSocket bindToAddress:@"0.0.0.0" port:20003 error:&error])
	{
		NSLog(@"Error binding: %@", error);
		return;
	}
	
	[udpSocket receiveWithTimeout:-1 tag:0];
    

    [mUdpTimer invalidate];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                      target:self selector:@selector(onBroadcastTimer:)
                                                    userInfo:nil repeats:YES];
    mUdpTimer = timer;
    
    // setup tcp server
    tcpListenSocket = [[AsyncSocket alloc] initWithDelegate:self];
    if(![tcpListenSocket acceptOnPort:mTcpPort error:&error])
    {
        NSLog(FORMAT(@"Error starting server: %@", error));
        return;
    }

}

- (IBAction)onStopServer:(id)sender {
    [mUdpTimer invalidate];
    [udpSocket close];
    [tcpListenSocket disconnect];
    [tcpConnectionSocket disconnect];
}



- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (msg)
	{
		NSLog(FORMAT(@"RECV: %@", msg));
	}
	else
	{
		NSLog(FORMAT(@"RECV: Unknown message from: %@:%hu", host, port));
	}
	
	[udpSocket receiveWithTimeout:-1 tag:0];
	return YES;
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket with ip:%@:%hu",[newSocket connectedHost],[newSocket connectedPort]);
    tcpConnectionSocket = newSocket;
    [mUdpTimer invalidate];
    [udpSocket close];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"Accepted client %@:%hu", host, port);
//	
//	NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
//	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
//	
//	[sock writeData:welcomeData withTimeout:-1 tag:0];
//	
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket didWriteDataWithTag with tag=%ld",tag);
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"didReadData===");
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
	if(msg)
	{
        [self translator:msg];
	}
	else
	{
		NSLog(@"Error converting received data into UTF-8 String");
	}
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}

/**
 * This method is called if a read has timed out.
 * It allows us to optionally extend the timeout.
 * We use this method to issue a warning to the user prior to disconnecting them.
 **/
- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
				   elapsed:(NSTimeInterval)elapsed
				 bytesDone:(NSUInteger)length
{
    NSLog(@"sockshouldTimeoutReadWithTag=====");
//	if(elapsed <= READ_TIMEOUT)
//	{
//		NSString *warningMsg = @"Are you still there?\r\n";
//		NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
//		
//		[sock writeData:warningData withTimeout:-1 tag:WARNING_MSG];
//		
//		return READ_TIMEOUT_EXTENSION;
//	}
//	
	return 0.0;
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(FORMAT(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]));
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	NSLog(@"disconnect===");
}

/*
 MOUSEEVENTF_MOVE x y
 MOUSEEVENTF_LEFTDOWN
 MOUSEEVENTF_LEFTUP
 MOUSEEVENTF_RIGHTDOWN
 MOUSEEVENTF_RIGHTUP
 MOUSEEVENTF_MIDDLEDOWN
 MOUSEEVENTF_MIDDLEUP
 MOUSEEVENTF_WHEEL WHEEL_DELTA
 */

- (void) translator:(NSString *)commandString
{
    NSLog(@"command message : %@",commandString);
    
    NSArray* commands = [commandString componentsSeparatedByString:@" "];
    NSString* command0 = [commands objectAtIndex:0];
    
    CGEventRef currentCursePositionEvent = CGEventCreate(NULL);
    CGPoint currentPoint = CGEventGetLocation(currentCursePositionEvent);
    CFRelease(currentCursePositionEvent);
    NSLog(@"Location? x= %f, y = %f", (float)currentPoint.x, (float)currentPoint.y);
    
    
    CGEventType eventType = kCGEventNull;
    CGMouseButton button = kCGMouseButtonLeft;
    if ([command0 caseInsensitiveCompare:@"MOUSEEVENTF_MOVE"] == NSOrderedSame ) {
        float offsetx = [[commands objectAtIndex:1] floatValue];
        float offsety = [[commands objectAtIndex:2] floatValue];
        currentPoint.x += offsetx;
        currentPoint.y += offsety;
        eventType = kCGEventMouseMoved;
    }else if([command0 caseInsensitiveCompare:@"MOUSEEVENTF_LEFTDOWN"] == NSOrderedSame){
        eventType = kCGEventLeftMouseDown;
    }else if([command0 caseInsensitiveCompare:@"MOUSEEVENTF_LEFTUP"] == NSOrderedSame){
        eventType = kCGEventLeftMouseUp;
    }else if([command0 caseInsensitiveCompare:@"MOUSEEVENTF_RIGHTDOWN"] == NSOrderedSame){
        eventType = kCGEventRightMouseDown;
        button = kCGMouseButtonRight;
    }else if([command0 caseInsensitiveCompare:@"MOUSEEVENTF_RIGHTUP"] == NSOrderedSame){
        eventType = kCGEventRightMouseUp;
        button = kCGMouseButtonRight;
    }else if([command0 caseInsensitiveCompare:@"MOUSEEVENTF_MIDDLEDOWN"] == NSOrderedSame){
        eventType = kCGEventOtherMouseDown;
        button = kCGMouseButtonCenter;
    }else if([command0 caseInsensitiveCompare:@"MOUSEEVENTF_MIDDLEUP"] == NSOrderedSame){
        eventType = kCGEventOtherMouseUp;
        button = kCGMouseButtonCenter;
    }else if([command0 caseInsensitiveCompare:@"MOUSEEVENTF_WHEEL"] == NSOrderedSame){
        eventType = kCGEventNull;
    }else {
        NSLog(@"commands error: %@",commandString);
        return;
    }
    CGEventRef event = NULL;
    if (eventType != kCGEventNull) {
        event = CGEventCreateMouseEvent(NULL, eventType, currentPoint, button);
        
    }else {
        event = CGEventCreateScrollWheelEvent(NULL,kCGScrollEventUnitPixel, 1, 120 * [[commands objectAtIndex:1] floatValue]);
    }
    if (event != NULL) {
        CGEventPost(kCGHIDEventTap, event);
        CFRelease(event);
    }
}
@end
