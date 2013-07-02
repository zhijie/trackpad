//
//  OZLTouchpadViewController.m
//  TrackPad
//
//  Created by Lee Zhijie on 9/21/12.
//  Copyright (c) 2012 Lee Zhijie. All rights reserved.
//

#import "OZLTouchpadViewController.h"

@interface OZLTouchpadViewController ()

@end

@implementation OZLTouchpadViewController
@synthesize mPanelView;
@synthesize mMiddleButton;
@synthesize serverListButton;

#define TCP_PORT 20015
#define UPDATE_INTERVAL 3000

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        serverIPList = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // wifi connection check
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    mWifiReachability = [Reachability reachabilityForLocalWiFi] ;
	[mWifiReachability startNotifier];
	[self updateInterfaceWithReachability: mWifiReachability];
    
    // Do any additional setup after loading the view from its nib.
    mUdpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [mUdpSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    mTcpPort = TCP_PORT;
    mUdpPort = mTcpPort + 1;
    
    NSError* error = nil;
    if (![mUdpSocket bindToPort:mUdpPort error:&error])
    {
        NSLog(@"Error starting server (bind): %@", error.description);
        return;
    }
    [mUdpSocket receiveWithTimeout:-1 tag:0];
    
    mTcpSocket = [[AsyncSocket alloc] initWithDelegate:self];
    [mTcpSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];

    // timer to update server list
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self selector:@selector(updateServerListByTime:)
                                                    userInfo:nil repeats:YES];
    serverListTimer = timer;
}

- (void) updateServerListByTime:(NSTimer*)theTimer
{
    NSDate* current = [NSDate date];
    int count = serverIPList.count;
    NSArray* values = [serverIPList allValues];
    NSArray* keys = [serverIPList allKeys];
    for (int i = count -1; i >=0; i--) {
        NSInteger interval = [current timeIntervalSinceDate:[values objectAtIndex:i]];
        if (interval > UPDATE_INTERVAL) {
            [serverIPList removeObjectForKey:[keys objectAtIndex:i]];
        }
    }
    [serverListButton setTitle:[NSString stringWithFormat:@"%d",serverIPList.count] forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [serverListTimer invalidate];
    serverListTimer = nil;
    
    if ([mTcpSocket isConnected]) {
        [mTcpSocket disconnect];
    }
    mTcpSocket = nil;
    if ([mUdpSocket isConnected]) {
        [mUdpSocket close];
    }
    mUdpSocket = nil;

    [self setMPanelView:nil];
    [self setMMiddleButton:nil];
    [self setServerListButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
- (IBAction)onShowServerList:(id)sender {
    serverIPListBack = [[NSMutableDictionary alloc] initWithDictionary:serverIPList copyItems:YES];
    
    UIActionSheet* serverlistSheet = [[UIActionSheet alloc] init];
    serverlistSheet.delegate = self;
    serverlistSheet.title = @"Detected IPs";
    for (NSString* ip in [serverIPListBack allKeys]) {
        [serverlistSheet addButtonWithTitle:ip];
    }
    serverlistSheet.cancelButtonIndex = [serverlistSheet addButtonWithTitle:@"Cancel"];

    [serverlistSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray* ips =[serverIPListBack allKeys];
    if (ips.count <= buttonIndex) {
        return;
    }
    NSString* serverIp = [ips objectAtIndex:buttonIndex];
    if ([mTcpSocket isConnected]) {
        [mTcpSocket disconnect];
    }
    NSError* error = nil;
    [mTcpSocket connectToHost:serverIp onPort:mTcpPort error:&error];
    if (error != nil) {
        NSLog(@"Error connecting tcp server : %@", error.description);
    }
}

- (IBAction)leftBtnDown:(id)sender {
    NSString* msg = @"MOUSEEVENTF_LEFTDOWN";
    [self sendMessage:msg];
}

- (IBAction)leftBtnUp:(id)sender {
    NSString* msg = @"MOUSEEVENTF_LEFTUP";
    [self sendMessage:msg];
}

- (IBAction)middleBtnDown:(id)sender forEvent:(UIEvent *)event {
    NSString* msg = @"MOUSEEVENTF_MIDDLEDOWN";
    [self sendMessage:msg];
    
    CGPoint point = [[[event allTouches] anyObject] locationInView:mMiddleButton];
    mLastPoint = point;
}

- (IBAction)middleBtnUp:(id)sender forEvent:(UIEvent *)event {
    NSString* msg = @"MOUSEEVENTF_MIDDLEUP";
    [self sendMessage:msg];
}

- (IBAction)middleBtnMove:(id)sender forEvent:(UIEvent *)event {
    CGPoint point = [[[event allTouches] anyObject] locationInView:mMiddleButton];
    float offsety = point.y - mLastPoint.y;
    NSString* msg = [NSString stringWithFormat:@"MOUSEEVENTF_WHEEL %f ",offsety/120];
    [self sendMessage:msg];
    
    mLastPoint = point;
}


- (IBAction)rightBtnDown:(id)sender {
    NSString* msg = @"MOUSEEVENTF_RIGHTDOWN";
    [self sendMessage:msg];
}

- (IBAction)rightBtnUp:(id)sender {
    NSString* msg = @"MOUSEEVENTF_RIGHTUP";
    [self sendMessage:msg];
}

- (IBAction)panelTouchDown:(id)sender forEvent:(UIEvent *)event {
    CGPoint point = [[[event allTouches] anyObject] locationInView:mPanelView];
    mLastPoint = point;
}

- (IBAction)panelTouchUp:(id)sender forEvent:(UIEvent *)event {

}

- (IBAction)panelMove:(id)sender forEvent:(UIEvent *)event {
    CGPoint point = [[[event allTouches] anyObject] locationInView:mPanelView];
    float offsetx = point.x - mLastPoint.x;
    float offsety = point.y - mLastPoint.y;
    NSString* msg = [NSString stringWithFormat:@"MOUSEEVENTF_MOVE %f %f",offsetx,offsety];
    [self sendMessage:msg];
    
    mLastPoint = point;
}

- (IBAction)panelTouchUpOutside:(id)sender {
}


- (void) sendMessage:(NSString*) msg
{
    NSData* data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [mTcpSocket writeData:data withTimeout:-1 tag:1];
    [mTcpSocket writeData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
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
        NSString* serverIp = host;
        NSLog(@"server ip retrived by broadcaster: %@",serverIp);

        if (![serverIp hasPrefix:@"::"]) {
            if ([serverIPList valueForKey:serverIp] == nil) {//not found
                // start tcp connection
                if (![mTcpSocket isConnected]) {
                    NSError* error = nil;
                    [mTcpSocket connectToHost:serverIp onPort:mTcpPort error:&error];
                    if (error != nil) {
                        NSLog(@"Error connecting tcp server : %@", error.description);
                    }
                }
            }
            [serverIPList setValue:[NSDate date] forKey:serverIp];
            [serverListButton setTitle:[NSString stringWithFormat:@"%d", serverIPList.count] forState:UIControlStateNormal];
        }
	}
	else
	{
		NSLog(@"Error converting received data into UTF-8 String");
	}


    [mUdpSocket receiveWithTimeout:-1 tag:0];
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
	NSLog(@"onSocket:didWriteDataWithTag:%ld", tag);
}


//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"WIFI Required"
                                  message: @"WIFI connection is necessory, Please make sure your WIFI is open. Please press HOME button to quit"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
            break;
        }
            
        case ReachableViaWWAN:
        {
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            break;
        }
    }

}

@end
