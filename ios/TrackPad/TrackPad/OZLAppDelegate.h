//
//  OZLAppDelegate.h
//  TrackPad
//
//  Created by Lee Zhijie on 9/20/12.
//  Copyright (c) 2012 Lee Zhijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OZLTouchpadViewController.h"

@class OZLViewController;

@interface OZLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) OZLTouchpadViewController *viewController;

@end
