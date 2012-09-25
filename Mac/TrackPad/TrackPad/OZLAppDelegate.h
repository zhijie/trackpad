//
//  OZLAppDelegate.h
//  TrackPad
//
//  Created by Lee Zhijie on 9/24/12.
//  Copyright (c) 2012 Lee Zhijie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>


@interface OZLAppDelegate : NSObject <NSApplicationDelegate> {
    @private
    CFSocketRef mSocket;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *mInfoTextField;
@property (weak) IBOutlet NSButton *mStartServerBtn;
@property (weak) IBOutlet NSButton *mStopServerBtn;
- (IBAction)onStartSever:(id)sender;
- (IBAction)onStopServer:(id)sender;

- (void) onSocketAccept:(void*)data;
- (void) onSocketConnect:(void*)data;
- (void) onSocketReceive:(void*)data;

@end
