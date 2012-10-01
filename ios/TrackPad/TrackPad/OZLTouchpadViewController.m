//
//  OZLTouchpadViewController.m
//  TrackPad
//
//  Created by Lee Zhijie on 9/21/12.
//  Copyright (c) 2012 Lee Zhijie. All rights reserved.
//

#import "OZLTouchpadViewController.h"

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@interface OZLTouchpadViewController ()

@end

@implementation OZLTouchpadViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    mUdpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    mTcpPort = 20000;
    mUdpPort = mTcpPort + 1;
    
    NSError* error = nil;
    if (![mUdpSocket bindToPort:mUdpPort error:&error])
    {
        NSLog(FORMAT(@"Error starting server (bind): %@", error));
        return;
    }
    
    [mUdpSocket receiveWithTimeout:-1 tag:0];
    
    mTcpSocket = [[AsyncSocket alloc] initWithDelegate:self];
    [mTcpSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
 Command :
 MOUSEEVENTF_MOVE x y
 MOUSEEVENTF_LEFTDOWN
 MOUSEEVENTF_LEFTUP
 MOUSEEVENTF_RIGHTDOWN
 MOUSEEVENTF_RIGHTUP
 MOUSEEVENTF_MIDDLEDOWN
 MOUSEEVENTF_MIDDLEUP
 MOUSEEVENTF_WHEEL WHEEL_DELTA=120
 
 reference :
 http://msdn.microsoft.com/en-us/library/windows/desktop/ms646273(v=vs.85).aspx
 */
- (IBAction)leftBtnDown:(id)sender {
    NSString* msg = @"MOUSEEVENTF_LEFTDOWN";
    [self sendMessage:msg];
}

- (IBAction)leftBtnUp:(id)sender {
    NSString* msg = @"MOUSEEVENTF_LEFTUP";
    [self sendMessage:msg];
}

- (IBAction)middleBtnDown:(id)sender {
    NSString* msg = @"MOUSEEVENTF_MIDDLEDOWN";
    [self sendMessage:msg];
}

- (IBAction)middleBtnUp:(id)sender {
    NSString* msg = @"MOUSEEVENTF_MIDDLEUP";
    [self sendMessage:msg];
}

- (IBAction)middleBtnMove:(id)sender {
    NSString* msg = @"MOUSEEVENTF_WHEEL";
    [self sendMessage:msg];
}

- (IBAction)rightBtnDown:(id)sender {
    NSString* msg = @"MOUSEEVENTF_RIGHTDOWN";
    [self sendMessage:msg];
}

- (IBAction)rightBtnUp:(id)sender {
    NSString* msg = @"MOUSEEVENTF_RIGHTUP";
    [self sendMessage:msg];
}

- (IBAction)panelTouchDown:(id)sender {

}

- (IBAction)panelTouchUp:(id)sender {

}

- (IBAction)panelTouchMove:(id)sender {
    //UITouch* touch =
    NSString* msg = @"MOUSEEVENTF_MOVE %f %f";
    [self sendMessage:[NSString stringWithFormat:msg]];
}

- (void) sendMessage:(NSString*) msg
{
    NSString* message = [NSString stringWithFormat:@"%@\r\n",msg];
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [mTcpSocket writeData:data withTimeout:-1 tag:1];
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
		NSLog(@"onUdpSocket: %@",msg);
        NSString* serverIp = host;
        
        NSLog(@"server ip retrived by broadcaster: %@",serverIp);
        
        [mUdpSocket close];

        // start tcp connection
        NSError* error = nil;
        [mTcpSocket connectToHost:serverIp onPort:mTcpPort error:&error];
        if (error != nil) {
            NSLog(FORMAT(@"Error connecting tcp server : %@", error));
        }
	}
	else
	{
		NSLog(@"Error converting received data into UTF-8 String");
	}
    
	return YES;
}

#pragma mark -
#pragma mark AsyncSocket Methods

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	NSLog(@"Disconnecting. Error: %@", [err localizedDescription]);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
	NSLog(@"tcp socket disconnected.");

}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
	NSLog(@"onSocketWillConnect:");
	return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
	NSLog(@"Connected To %@:%i.", host, port);
    

}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
	NSLog(@"onSocket:didWriteDataWithTag:%i", tag);
}

@end
