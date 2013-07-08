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
#import "Reachability.h"

@interface OZLTouchpadViewController : UIViewController<UIActionSheetDelegate>
{
    AsyncSocket* mTcpSocket;
    AsyncUdpSocket* mUdpSocket;
    int mUdpPort;
    int mTcpPort;

    NSMutableDictionary* serverIPList;//store ip list and last connected timestamp
    NSMutableDictionary* serverIPListBack;//used when popup actionsheet

    CGPoint mLastPoint;
    
    Reachability* mWifiReachability;
    NSTimer* serverListTimer;
}
@property (strong, nonatomic) IBOutlet UIButton *mPanelView;
@property (strong, nonatomic) IBOutlet UIButton *mMiddleButton;

@property (weak, nonatomic) IBOutlet UIButton *serverListButton;
- (IBAction)onShowServerList:(id)sender;

- (IBAction)leftBtnDown:(id)sender;
- (IBAction)leftBtnUp:(id)sender;
- (IBAction)middleBtnDown:(id)sender forEvent:(UIEvent *)event;
- (IBAction)middleBtnUp:(id)sender forEvent:(UIEvent *)event;
- (IBAction)middleBtnMove:(id)sender forEvent:(UIEvent *)event;
- (IBAction)rightBtnDown:(id)sender;
- (IBAction)rightBtnUp:(id)sender;
- (IBAction)panelTouchDown:(id)sender forEvent:(UIEvent *)event;
- (IBAction)panelTouchUp:(id)sender forEvent:(UIEvent *)event;
- (IBAction)panelMove:(id)sender forEvent:(UIEvent *)event;
- (IBAction)panelTouchUpOutside:(id)sender;

- (void) sendMessage:(NSString*)msg;
- (void) reachabilityChanged: (NSNotification* )note;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
@end
