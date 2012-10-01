//
//  OZLAppDelegate.h
//  TrackPad
//
//  Created by Lee Zhijie on 9/24/12.
//  Copyright (c) 2012 Lee Zhijie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"

@interface OZLAppDelegate : NSObject <NSApplicationDelegate>
{
    int mTcpPort ;
    int mBroadcastPort;
    long tag;
	AsyncUdpSocket *udpSocket;
    AsyncSocket* tcpListenSocket;
    AsyncSocket* tcpConnectionSocket;
    NSTimer* mUdpTimer;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *mInfoTextField;
@property (weak) IBOutlet NSButton *mStartServerBtn;
@property (weak) IBOutlet NSButton *mStopServerBtn;
- (IBAction)onStartSever:(id)sender;
- (IBAction)onStopServer:(id)sender;


- (void) onBroadcastTimer:(NSTimer*)theTimer;
- (void) translator:(NSString*) commandString;
@end
