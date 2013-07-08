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

#define READ_TIMEOUT -1
#define READ_TIMEOUT_EXTENSION 10.0

#define TCP_PORT 20015

@implementation OZLAppDelegate
@synthesize mInfoTextField;
@synthesize mStartServerBtn;
@synthesize mStopServerBtn;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    mTcpPort = TCP_PORT;
    mBroadcastPort = mTcpPort +1;
    
    [self activateStatusMenu];
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    [self quitApp:nil];
}

- (void) quitApp :(id)sender
{
    [self onStopServer:nil];
    [NSApp terminate:nil];
}


- (void) onBroadcastTimer:(NSTimer*)theTimer
{
    NSString* msg = @"broadcasting";
	NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
	[udpSocket sendData:data toHost:@"255.255.255.255" port:mBroadcastPort withTimeout:-1 tag:tag++];
    NSLog(@"sending with msg:%@ with :%ld",msg,tag);

}

- (IBAction)onStartSever:(id)sender {
    tcpConnectionSockets = [[NSMutableArray alloc] init];
    
    //broadcast && timer to build connection
    udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
	[udpSocket enableBroadcast:YES error:nil];
	NSError *error = nil;
	
	if (![udpSocket bindToAddress:@"0.0.0.0" port:mBroadcastPort error:&error])
	{
		NSLog(@"Error binding: %@", error);
		return;
	}
	
	//[udpSocket receiveWithTimeout:-1 tag:0];

    [mUdpTimer invalidate];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self selector:@selector(onBroadcastTimer:)
                                                    userInfo:nil repeats:YES];
    mUdpTimer = timer;
    
    // setup tcp server
    tcpListenSocket = [[AsyncSocket alloc] initWithDelegate:self];
    if(![tcpListenSocket acceptOnPort:mTcpPort error:&error])
    {
        NSLog(@"Error starting server: %@", error.description);
        return;
    }

}

- (IBAction)onStopServer:(id)sender {
    [mUdpTimer invalidate];
    [udpSocket close];
    udpSocket = nil;
    [tcpListenSocket disconnect];
    tcpConnectionSockets = nil;
    for (AsyncSocket* socket in tcpConnectionSockets) {
        [socket disconnect];
    }
    tcpConnectionSockets = nil;
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
		NSLog(@"RECV: %@", msg);
	}
	else
	{
		NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
	}
	
	[udpSocket receiveWithTimeout:-1 tag:0];
	return YES;
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket with ip:%@:%hu",[newSocket connectedHost],[newSocket connectedPort]);
    [tcpConnectionSockets addObject: newSocket];
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
	NSLog(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	NSLog(@"disconnect===");
    [tcpConnectionSockets removeObject:sock];
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

- (void)activateStatusMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    
    statusbarItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    
    [statusbarItem setTitle: NSLocalizedString(@"TrackPad",@"")];
    [statusbarItem setHighlightMode:YES];
    
    NSMenu* statusmenu = [[NSMenu alloc] initWithTitle:@"menu"];
    NSMenuItem* quitItem = [[NSMenuItem alloc] initWithTitle:@"quite" action:@selector(quitApp:) keyEquivalent:@""];
    NSMenuItem* startServerItem = [[NSMenuItem alloc] initWithTitle:@"Start Server" action:@selector(onStartSever:) keyEquivalent:@""];
    NSMenuItem* stopServerItem = [[NSMenuItem alloc] initWithTitle:@"Stop Server" action:@selector(onStopServer:) keyEquivalent:@""];
    [startServerItem setTarget:self];
    [stopServerItem setTarget:self];
    [quitItem setTarget:self];
    [statusmenu addItem:startServerItem];
    [statusmenu addItem:stopServerItem];
    [statusmenu addItem:quitItem];
    [statusbarItem setMenu:statusmenu];
}
@end
