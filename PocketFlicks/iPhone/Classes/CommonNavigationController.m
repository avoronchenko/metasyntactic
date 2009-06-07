// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "CommonNavigationController.h"

#import "Application.h"
#import "Controller.h"
#import "Model.h"
#import "Movie.h"
#import "MovieDetailsViewController.h"
#import "PostersViewController.h"
#import "ReviewsViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "Theater.h"
#import "TheaterDetailsViewController.h"
#import "TicketsViewController.h"

#ifndef IPHONE_OS_VERSION_3
#endif

@interface CommonNavigationController()
@property (retain) PostersViewController* postersViewController;
#ifndef IPHONE_OS_VERSION_3
@property (retain) SearchViewController* searchViewController;
#endif
@end


@implementation CommonNavigationController

@synthesize postersViewController;
#ifndef IPHONE_OS_VERSION_3
@synthesize searchViewController;
#endif

- (void) dealloc {
    self.postersViewController = nil;

#ifndef IPHONE_OS_VERSION_3
    self.searchViewController = nil;
#endif

    [super dealloc];
}


- (void) didReceiveMemoryWarning {
    if (postersViewController != nil) {
        return;
    }

    [super didReceiveMemoryWarning];
}


- (Model*) model {
    return [Model model];
}


- (Controller*) controller {
    return [Controller controller];
}


- (Movie*) movieForTitle:(NSString*) canonicalTitle {
    for (Movie* movie in self.model.movies) {
        if ([movie.canonicalTitle isEqual:canonicalTitle]) {
            return movie;
        }
    }

    return nil;
}


- (Theater*) theaterForName:(NSString*) name {
    for (Theater* theater in self.model.theaters) {
        if ([theater.name isEqual:name]) {
            return theater;
        }
    }

    return nil;
}


- (void) navigateToLastViewedPage {
    NSArray* types = self.model.navigationStackTypes;
    NSArray* values = self.model.navigationStackValues;

    for (int i = 0; i < types.count; i++) {
        NSInteger type = [[types objectAtIndex:i] intValue];
        id value = [values objectAtIndex:i];

        if (type == MovieDetails) {
            Movie* movie = [self movieForTitle:value];
            [self pushMovieDetails:movie animated:NO];
        } else if (type == TheaterDetails) {
            Theater* theater = [self theaterForName:value];
            [self pushTheaterDetails:theater animated:NO];
        } else if (type == Reviews) {
            Movie* movie = [self movieForTitle:value];
            [self pushReviews:movie animated:NO];
        } else if (type == Tickets) {
            Movie* movie = [self movieForTitle:[value objectAtIndex:0]];
            Theater* theater = [self theaterForName:[value objectAtIndex:1]];
            NSString* title = [value objectAtIndex:2];

            [self pushTicketsView:movie theater:theater title:title animated:NO];
        }
    }
}


- (void) pushReviews:(Movie*) movie animated:(BOOL) animated {
    ReviewsViewController* controller = [[[ReviewsViewController alloc] initWithMovie:movie] autorelease];

    [self pushViewController:controller animated:animated];
}


- (void) pushMovieDetails:(Movie*) movie
                 animated:(BOOL) animated {
    if (movie == nil) {
        return;
    }

    UIViewController* viewController = [[[MovieDetailsViewController alloc] initWithMovie:movie] autorelease];
    [self pushViewController:viewController animated:animated];
}


- (void) pushTheaterDetails:(Theater*) theater animated:(BOOL) animated {
    if (theater == nil) {
        return;
    }

    UIViewController* viewController = [[[TheaterDetailsViewController alloc] initWithTheater:theater] autorelease];
    [self pushViewController:viewController animated:animated];
}


- (void) pushTicketsView:(Movie*) movie
                 theater:(Theater*) theater
                   title:(NSString*) title
                animated:(BOOL) animated {
    if (movie == nil || theater == nil) {
        return;
    }

    UIViewController* viewController = [[[TicketsViewController alloc] initWithTheater:theater
                                                                                 movie:movie
                                                                                 title:title] autorelease];

    [self pushViewController:viewController animated:animated];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
    [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }

    return self.model.screenRotationEnabled && postersViewController == nil;
}


- (void) hidePostersView {
    [self popViewControllerAnimated:YES];
    self.postersViewController = nil;
}


- (void) showPostersView:(Movie*) movie posterCount:(NSInteger) posterCount {
    if (postersViewController != nil) {
        [self hidePostersView];
    }

    self.postersViewController =
    [[[PostersViewController alloc] initWithMovie:movie
                                      posterCount:posterCount] autorelease];

    [self pushViewController:postersViewController animated:YES];
}


- (void) pushInfoControllerAnimated:(BOOL) animated {
    UIViewController* controller = [[[SettingsViewController alloc] init] autorelease];

#if IPHONE_OS_VERSION_3
    UINavigationController* navigationController = [[[AbstractNavigationController alloc] initWithRootViewController:controller] autorelease];
    if (![Application isIPhone]) {
        navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self presentModalViewController:navigationController animated:YES];
#else
    [self pushViewController:controller animated:YES];
#endif
}

#ifndef IPHONE_OS_VERSION_3
- (void) showSearchView {
    if (searchViewController == nil) {
        self.searchViewController = [[[SearchViewController alloc] init] autorelease];
    }

    [self pushViewController:searchViewController animated:YES];
}
#endif


- (void) onTabBarItemSelected {
    for (id controller in self.viewControllers) {
        if ([controller respondsToSelector:@selector(onTabBarItemSelected)]) {
            [controller onTabBarItemSelected];
        }
    }
}

@end