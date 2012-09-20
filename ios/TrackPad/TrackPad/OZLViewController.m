//
//  OZLViewController.m
//  TrackPad
//
//  Created by Lee Zhijie on 9/20/12.
//  Copyright (c) 2012 Lee Zhijie. All rights reserved.
//

#import "OZLViewController.h"

@interface OZLViewController ()

@end

@implementation OZLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
