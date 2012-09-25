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


@implementation OZLAppDelegate
@synthesize mInfoTextField;
@synthesize mStartServerBtn;
@synthesize mStopServerBtn;

- (void) onSocketAccept:(void*)data
{
    CFSocketNativeHandle nativeSocketHandle = (CFSocketNativeHandle)data;
    
    uint8_t name[SOCK_MAXADDRLEN];
    socklen_t namelen = sizeof(name);
    if(0 != getpeername(nativeSocketHandle ,(struct sockaddr*)name,&namelen))
    {
        exit(1);
    }
    //printf("%s connected\n",inet_ntoa((struct sockaddr *)name)->sin_addr);
    //////////////////////
    
    CFReadStreamRef  iStream;
    CFWriteStreamRef  oStream;
    CFStreamCreatePairWithSocket(       // 创建一个可读写的socket连接
                                 kCFAllocatorDefault,
                                 nativeSocketHandle,
                                 &iStream,
                                 &oStream);
    if(iStream && oStream){
        CFStreamClientContext streamCtxt = {0,NULL, NULL, NULL, NULL};
        if(!CFReadStreamSetClient(
                                  iStream,
                                  kCFStreamEventHasBytesAvailable //有可用数据则执行
                                  nil,                      //设置读取时候的函数
                                  &steamCtxt))
        {exit(1);}
        
        if(!CFWriteStreamSetClient(       //为流指定一个在运行循环中接受回调的客户端
                                   oStream,
                                   kCFStreamEventCanAcceptBytes, //输出流准备完毕，可输出
                                   nil,                    //设置写入时候的函数
                                   &streamCtxt))
        {exit(1);}
}
    
- (void) onSocketConnect:(void*)data
{
    
}
- (void) onSocketReceive:(void*)data
{
    
}

static void socketCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    if (data != NULL) {
        NSLog(@"callback error");
        return;
    }
    OZLAppDelegate *delegate = (__bridge OZLAppDelegate *)info;
    switch (type) {
        case kCFSocketAcceptCallBack:
            [delegate performSelectorInBackground:@selector(onSocketAccept) withObject:data];
            break;
        case kCFSocketConnectCallBack:
            [delegate performSelectorInBackground:@selector(onSocketConnect) withObject:data];
            break;
        case kCFSocketReadCallBack:
            [delegate performSelectorInBackground:@selector(onSocketReceive) withObject:data];
            break;
            
        default:
            break;
    }
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)onStartSever:(id)sender {
    CFSocketContext ctx = {0, (__bridge void *)(self), NULL, NULL, NULL};
    mSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack | kCFSocketAcceptCallBack | kCFSocketDataCallBack | kCFSocketReadCallBack, nil, &ctx);
    int yes = 1 ;
    setsockopt(CFSocketGetNative(mSocket),SOL_SOCKET, SO_REUSEADDR,(void*)&yes,sizeof(yes));
    
    /* Set the port and address we want to listen on */
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(20000);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr, sizeof(addr));
    
    CFSocketConnectToAddress(mSocket, address, -1);
    
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, mSocket, 0);
    CFRunLoopAddSource(cfrl, source, kCFRunLoopCommonModes);
    CFRelease(source);
}

- (IBAction)onStopServer:(id)sender {
    
}
@end
