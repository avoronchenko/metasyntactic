//
//  NotificationCenter.m
//  NowPlaying
//
//  Created by Cyrus Najmabadi on 2/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NotificationCenter.h"

@interface NotificationCenter()
@property (retain) UIWindow* window;
@property (retain) UILabel* notificationLabel;
@property (retain) UILabel* blackLabel;
@end

@implementation NotificationCenter

@synthesize window;
@synthesize notificationLabel;
@synthesize blackLabel;

- (void) dealloc {
    self.window = nil;
    self.notificationLabel = nil;
    self.blackLabel = nil;

    [super dealloc];
}


- (id) initWithWindow:(UIWindow*) window_ {
    if (self = [super init]) {
        self.window = window_;

        self.notificationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 417, 320, 16)] autorelease];
        notificationLabel.font = [UIFont boldSystemFontOfSize:12];
        notificationLabel.textAlignment = UITextAlignmentCenter;
        notificationLabel.textColor = [UIColor whiteColor];
        notificationLabel.shadowColor = [UIColor darkGrayColor];
        notificationLabel.shadowOffset = CGSizeMake(0, 1);
        notificationLabel.alpha = 0;
        notificationLabel.backgroundColor = [UIColor colorWithRed:46.0/256.0 green:46.0/256.0 blue:46.0/256.0 alpha:1];

        self.blackLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 417, 320, 1)] autorelease];
        blackLabel.backgroundColor = [UIColor blackColor];
    }

    return self;
}


+ (NotificationCenter*) centerWithWindow:(UIWindow*) window {
    return [[[NotificationCenter alloc] initWithWindow:window] autorelease];
}


- (void) addToWindow {
    [window addSubview:notificationLabel];
    [window addSubview:blackLabel];
}


- (void) showNotification:(NSString*) message {
    notificationLabel.text = message;

    [UIView beginAnimations:nil context:NULL];
    {
        notificationLabel.alpha = blackLabel.alpha = 1;
    }
    [UIView commitAnimations];
}


- (void) hideNotification {
    [UIView beginAnimations:nil context:NULL];
    {
        notificationLabel.alpha = blackLabel.alpha = 0;
    }
    [UIView commitAnimations];
}


- (void) willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation {
    notificationLabel.alpha = blackLabel.alpha = 0;
    [blackLabel removeFromSuperview];
    [notificationLabel removeFromSuperview];
}


- (void) didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(showLabels) withObject:nil afterDelay:1];
}


- (void) showLabels {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        [self addToWindow];
        [self showNotification:notificationLabel.text];
    }
}

@end