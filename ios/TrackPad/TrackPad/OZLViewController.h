//
//  OZLViewController.h
//  TrackPad
//
//  Created by Lee Zhijie on 9/20/12.
//  Copyright (c) 2012 Lee Zhijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OZLViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *mServerIPTextField;
@property (strong, nonatomic) IBOutlet UITextField *mServerPortTextField;
- (IBAction)onClickConnection:(id)sender;

@end
