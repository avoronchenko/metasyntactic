// Copyright (C) 2008 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import "NumbersViewController.h"

#import "ColorCache.h"
#import "ImageCache.h"
#import "MovieNumbers.h"
#import "NowPlayingModel.h"
#import "NumbersCache.h"
#import "NumbersNavigationController.h"
#import "SettingCell.h"

@implementation NumbersViewController

@synthesize navigationController;
@synthesize segmentedControl;
@synthesize movieNumbers;

- (void) dealloc {
    self.navigationController = nil;
    self.segmentedControl = nil;
    self.movieNumbers = nil;

    [super dealloc];
}


- (id) initWithNavigationController:(NumbersNavigationController*) controller {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.navigationController = controller;
        self.title = NSLocalizedString(@"Numbers", nil);

        self.segmentedControl = [[[UISegmentedControl alloc] initWithItems:
                                  [NSArray arrayWithObjects:
                                   NSLocalizedString(@"Daily", nil),
                                   NSLocalizedString(@"Weekend", nil),
                                   NSLocalizedString(@"Total", nil), nil]] autorelease];

        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        segmentedControl.selectedSegmentIndex = self.model.numbersSelectedSegmentIndex;
        [segmentedControl addTarget:self
                             action:@selector(onFilterChanged:)
                   forControlEvents:UIControlEventValueChanged];

        CGRect rect = segmentedControl.frame;
        rect.size.width = 240;
        segmentedControl.frame = rect;

        self.navigationItem.titleView = segmentedControl;
    }

    return self;
}


- (void) onFilterChanged:(id) sender {
    self.model.numbersSelectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    [self refresh];
}


- (void) viewWillAppear:(BOOL) animated {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.model.activityView] autorelease];

    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];

    [self refresh];
}


NSComparisonResult compareMoviesByTotalGross(id i1, id i2, void* context) {
    MovieNumbers* m1 = i1;
    MovieNumbers* m2 = i2;
    
    if (m1.totalGross > m2.totalGross) {
        return NSOrderedAscending;
    } else if (m1.totalGross < m2.totalGross) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}


- (void) refresh {
    if (self.model.numbersSortingByDailyGross) {
        self.movieNumbers = self.model.numbersCache.dailyNumbers;
    } else if (self.model.numbersSortingByWeekendGross) {
        self.movieNumbers = self.model.numbersCache.weekendNumbers;
    } else if (self.model.numbersSortingByTotalGross) {
        NSMutableArray* movies = [NSMutableArray arrayWithArray:self.model.numbersCache.dailyNumbers];
        [movies sortUsingFunction:compareMoviesByTotalGross context:NULL];
        self.movieNumbers = movies;
    }
    
    [self.tableView reloadData];
}


- (NowPlayingModel*) model {
    return navigationController.model;
}


- (NowPlayingController*) controller {
    return navigationController.controller;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return MAX(1, self.movieNumbers.count);
}


- (NSInteger)     tableView:(UITableView*) tableView
      numberOfRowsInSection:(NSInteger) section {
    if (self.movieNumbers.count == 0) {
        return 0;
    }

    if (self.model.numbersSortingByTotalGross) {
        return 5;
    } else {
        return 6;
    }
}


- (UITableViewCell*) headerCellForSection:(NSInteger) section {
    static NSString* reuseIdentifier = @"NumbersViewTitleCellIdentifier";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
        
        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(43, 16, 0, 0)] autorelease];
        label.font = [UIFont systemFontOfSize:12];
        label.tag = 1;
        
        [cell addSubview:label];
    }
    
    MovieNumbers* numbers = [self.movieNumbers objectAtIndex:section];
    UILabel* label = (id)[cell viewWithTag:1];

    if (numbers.previousRank == 0 || numbers.currentRank == numbers.previousRank) {
        cell.image = [ImageCache neutralSquare];
        label.text = nil;
    } else if (numbers.currentRank > numbers.previousRank) {
        cell.image = [ImageCache upArrow];
        label.text = [NSString stringWithFormat:@"+%d", numbers.currentRank - numbers.previousRank];
    } else {
        cell.image = [ImageCache downArrow];
        label.text = [NSString stringWithFormat:@"-%d", numbers.previousRank - numbers.currentRank];
    }

    [label sizeToFit];

    cell.text = [NSString stringWithFormat:@"   %@", numbers.canonicalTitle];

    return cell;
}


- (NSNumberFormatter*) currencyFormatter {
    NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.maximumFractionDigits = 0;
    formatter.currencySymbol = @"";
    return formatter;
}


- (UITableViewCell*) tableView:(UITableView*) tableView
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.row == 0) {
        return [self headerCellForSection:indexPath.section];
    }
    
    static NSString* reuseIdentifier = @"NumbersViewDetailCellIdentifier";
    SettingCell* cell = (id)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[SettingCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(0, -1, 300, 2)] autorelease];
        label.backgroundColor = [UIColor whiteColor];
        label.tag = 1;
        [cell.contentView addSubview:label];
    }
    
    UIView* label = [cell viewWithTag:1];
    label.hidden = (indexPath.row == 1);

    [cell setValueColor:[ColorCache commandColor]];
    
    MovieNumbers* movie = [self.movieNumbers objectAtIndex:indexPath.section];
    
    if (indexPath.row == 1) {  
        [cell setKey:NSLocalizedString(@"Days in theater", nil)
               value:[NSString stringWithFormat:@"%d", movie.days]];
    } else if (indexPath.row == 2) {
        [cell setKey:NSLocalizedString(@"Theaters", nil)
               value:[NSString stringWithFormat:@"%d", movie.theaters]];
    } else if (indexPath.row == 3) {
        double change;

        if (self.model.numbersSortingByDailyGross) {
            change = [self.model.numbersCache dailyChange:movie];
        } else if (self.model.numbersSortingByWeekendGross) {
            change = [self.model.numbersCache weekendChange:movie];
        } else {
            change = [self.model.numbersCache totalChange:movie];
        }
        
        NSString* value;
        if (IS_RETRIEVING(change)) {
            value = NSLocalizedString(@"Retrieving...", nil);
            [cell setValueColor:[UIColor grayColor]];
        } else if (IS_NOT_ENOUGH_DATA(change)) {
            value = NSLocalizedString(@"Not enough data", nil);
            [cell setValueColor:[UIColor grayColor]];
        } else {
            NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
            formatter.numberStyle = NSNumberFormatterPercentStyle;
            formatter.minimumFractionDigits = 2;
            formatter.maximumFractionDigits = 2;
            value = [formatter stringFromNumber:[NSNumber numberWithDouble:change]];
            
            if (change < 0) {
                [cell setValueColor:[UIColor redColor]];
            } else if (change > 0) {
                [cell setValueColor:[UIColor colorWithHue:120.0/360.0 saturation:0.75 brightness:0.75 alpha:1.0]];
            } else {
                [cell setValueColor:[UIColor grayColor]];
            }
        }
        
        if (self.model.numbersSortingByDailyGross) {
            [cell setKey:NSLocalizedString(@"Daily change", nil)
                   value:value];
        } else if (self.model.numbersSortingByWeekendGross) {
            [cell setKey:NSLocalizedString(@"Weekend change", nil)
                   value:value];
        } else {
            [cell setKey:NSLocalizedString(@"Total change", nil)
                   value:value];
        }
    } else if (indexPath.row == 4) {
        NSString* gross = [self.currencyFormatter stringFromNumber:[NSNumber numberWithInt:movie.totalGross]];
        NSString* value = [NSString stringWithFormat:@"$%@", gross];
        
        [cell setKey:NSLocalizedString(@"Total gross", nil)
               value:value];
        
    } else if (indexPath.row == 5) { 
        NSString* gross = [self.currencyFormatter stringFromNumber:[NSNumber numberWithInt:movie.currentGross]];
        NSString* value = [NSString stringWithFormat:@"$%@", gross];
        
        if (self.model.numbersSortingByDailyGross) {
            [cell setKey:NSLocalizedString(@"Daily gross", nil)
                   value:value];
        } else {
            [cell setKey:NSLocalizedString(@"Weekend gross", nil)
                   value:value];
        }
    }
    
    return cell;
}


- (CGFloat)         tableView:(UITableView*) tableView
      heightForRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.row == 0) {
        return tableView.rowHeight;
    }
    
    return tableView.rowHeight - 16;
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.row > 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
    if (self.model.numbersSortingByTotalGross) {
        NSInteger index = [self.model.numbersCache.dailyNumbers indexOfObject:[self.movieNumbers objectAtIndex:section]];
        if (index != NSNotFound) {
            return [NSString stringWithFormat:@"#%d", index + 1];
        }
    }

    return [NSString stringWithFormat:@"#%d", section + 1];
}


@end