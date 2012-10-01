//
//  OZLTouchpadViewController.h
//  TrackPad
//
//  Created by Lee Zhijie on 9/21/12.
//  Copyright (c) 2012 Lee Zhijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"

@interface OZLTouchpadViewController : UIViewController
{
    AsyncSocket* mTcpSocket;
    AsyncUdpSocket* mUdpSocket;
    int mUdpPort;
    int mTcpPort;
}

- (IBAction)leftBtnDown:(id)sender;
- (IBAction)leftBtnUp:(id)sender;
- (IBAction)middleBtnDown:(id)sender;
- (IBAction)middleBtnUp:(id)sender;
- (IBAction)middleBtnMove:(id)sender;
- (IBAction)rightBtnDown:(id)sender;
- (IBAction)rightBtnUp:(id)sender;
- (IBAction)panelTouchDown:(id)sender;
- (IBAction)panelTouchUp:(id)sender;
- (IBAction)panelTouchMove:(id)sender;

- (void) sendMessage:(NSString*)msg;
@end
