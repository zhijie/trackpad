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
@synthesize mTouchImageLeft;
@synthesize mTouchImageMiddle;
@synthesize mTouchImageRight;
@synthesize mTouchpanel;

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
}

- (void)viewDidUnload
{
    [self setMTouchImageLeft:nil];
    [self setMTouchImageMiddle:nil];
    [self setMTouchImageRight:nil];
    [self setMTouchpanel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
