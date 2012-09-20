//
//  OZLTouchpadViewController.h
//  TrackPad
//
//  Created by Lee Zhijie on 9/21/12.
//  Copyright (c) 2012 Lee Zhijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OZLTouchImageView.h"

@interface OZLTouchpadViewController : UIViewController

@property (strong, nonatomic) IBOutlet OZLTouchImageView *mTouchImageLeft;
@property (strong, nonatomic) IBOutlet OZLTouchImageView *mTouchImageMiddle;
@property (strong, nonatomic) IBOutlet OZLTouchImageView *mTouchImageRight;
@property (strong, nonatomic) IBOutlet OZLTouchImageView *mTouchpanel;

@end
