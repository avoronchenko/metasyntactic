//
//  ApplicationTabBarController.m
//  BoxOffice
//
//  Created by Cyrus Najmabadi on 4/30/08.
//  Copyright 2008 Metasyntactic. All rights reserved.
//

#import "ApplicationTabBarController.h"
#import "BoxOfficeAppDelegate.h"
#import "Utilities.h"

@implementation ApplicationTabBarController

@synthesize moviesNavigationController;
@synthesize theatersNavigationController;
@synthesize searchNavigationController;
@synthesize settingsNavigationController;
@synthesize appDelegate;

- (void) dealloc
{
    self.moviesNavigationController = nil;
    self.theatersNavigationController = nil;
    self.searchNavigationController = nil;
    self.settingsNavigationController = nil;
    self.appDelegate = nil;
    [super dealloc];
}

- (id) initWithAppDelegate:(BoxOfficeAppDelegate*) appDel
{
    if (self = [super init])
    {
        self.appDelegate = appDel;
        self.moviesNavigationController = [[[MoviesNavigationController alloc] initWithTabBarController:self] autorelease];
        self.theatersNavigationController = [[[TheatersNavigationController alloc] initWithTabBarController:self] autorelease];
        //self.searchNavigationController = [[[SearchNavigationController alloc] initWithTabBarController:self] autorelease];
        self.settingsNavigationController = [[[SettingsNavigationController alloc] initWithTabBarController:self] autorelease];
        
        self.viewControllers =
        [NSArray arrayWithObjects:
         moviesNavigationController,
         theatersNavigationController,
         //searchNavigationController,
         settingsNavigationController, nil];
        
        if ([Utilities isNilOrEmpty:[[self model] zipcode]]) {
            self.selectedViewController = self.settingsNavigationController;
        } else {
            AbstractNavigationController* controller = [self.viewControllers objectAtIndex:[self.model selectedTabBarViewControllerIndex]];
            self.selectedViewController = controller;
            [controller navigateToLastViewedPage];
        }
        
        self.delegate = self;
    }
    
    return self;
}

+ (ApplicationTabBarController*) controllerWithAppDelegate:(BoxOfficeAppDelegate*) appDelegate
{
    return [[[ApplicationTabBarController alloc] initWithAppDelegate:appDelegate] autorelease];
}

- (void)       tabBarController:(UITabBarController*) tabBarController
        didSelectViewController:(UIViewController*) viewController {
    [[self model] setSelectedTabBarViewControllerIndex:self.selectedIndex];
}

- (BoxOfficeModel*) model
{
    return [self.appDelegate model];
}

- (BoxOfficeController*) controller
{
    return [self.appDelegate controller];
}

- (void) refresh
{
    [self.moviesNavigationController refresh];
    [self.theatersNavigationController refresh];
    [self.settingsNavigationController refresh];
}

- (void) showTheaterDetails:(Theater*) theater {
    self.selectedViewController = self.theatersNavigationController;
    [self.theatersNavigationController pushTheaterDetails:theater animated:YES];
}

- (void) showMovieDetails:(Movie*) movie {
    self.selectedViewController = self.moviesNavigationController;
    [self.moviesNavigationController pushMovieDetails:movie animated:YES];    
}

@end
