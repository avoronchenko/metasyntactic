// Copyright 2010 Cyrus Najmabadi
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

#import "DateUtilities.h"

#import "AutoreleasingMutableDictionary.h"
#import "MetasyntacticSharedApplication.h"

@implementation DateUtilities

static NSCalendar* calendar;
static NSDate* today;
static NSRecursiveLock* gate = nil;

// Shared across threads.
static AutoreleasingMutableDictionary* timeDifferenceMap;
static AutoreleasingMutableDictionary* iso8601Map;

static NSDateFormatter* shortDateFormatter;
static NSDateFormatter* mediumDateFormatter;
static NSDateFormatter* longDateFormatter;
static NSDateFormatter* fullDateFormatter;
static NSDateFormatter* shortTimeFormatter;
static NSDateFormatter* yearFormatter;


static NSMutableDictionary* yearsAgoMap;
static NSMutableDictionary* monthsAgoMap;
static NSMutableDictionary* weeksAgoMap;


static BOOL use24HourTime;

+ (void) initialize {
  if (self == [DateUtilities class]) {
    gate = [[NSRecursiveLock alloc] init];

    timeDifferenceMap = [[AutoreleasingMutableDictionary dictionary] retain];
    iso8601Map = [[AutoreleasingMutableDictionary dictionary] retain];
    calendar = [[NSCalendar currentCalendar] retain];
    {
      NSDateComponents* todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                      fromDate:[NSDate date]];
      todayComponents.hour = 12;
      today = [[calendar dateFromComponents:todayComponents] retain];
    }

    yearsAgoMap = [[NSMutableDictionary alloc] init];
    monthsAgoMap = [[NSMutableDictionary alloc] init];
    weeksAgoMap = [[NSMutableDictionary alloc] init];

    {
      shortDateFormatter = [[NSDateFormatter alloc] init];
      [shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
      [shortDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }

    {
      mediumDateFormatter = [[NSDateFormatter alloc] init];
      [mediumDateFormatter setDateStyle:NSDateFormatterMediumStyle];
      [mediumDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }

    {
      longDateFormatter = [[NSDateFormatter alloc] init];
      [longDateFormatter setDateStyle:NSDateFormatterLongStyle];
      [longDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }

    {
      fullDateFormatter = [[NSDateFormatter alloc] init];
      [fullDateFormatter setDateStyle:NSDateFormatterFullStyle];
      [fullDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }

    {
      shortTimeFormatter = [[NSDateFormatter alloc] init];
      [shortTimeFormatter setDateStyle:NSDateFormatterNoStyle];
      [shortTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    }

    {
      yearFormatter = [[NSDateFormatter alloc] init];
      [yearFormatter setDateFormat:@"YYYY"];
    }

    {
      NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
      [formatter setTimeStyle:NSDateFormatterLongStyle];
      use24HourTime = [[formatter dateFormat] rangeOfString:@"H"].length != 0;
    }
  }
}


+ (NSString*) agoString:(NSInteger) time
                    map:(NSMutableDictionary*) map
               singular:(NSString*) singular
                 plural:(NSString*) plural {
  if (time == 1) {
    return singular;
  } else {
    NSNumber* number = [NSNumber numberWithInteger:time];
    NSString* result = [map objectForKey:number];
    if (result == nil) {
      result = [NSString stringWithFormat:plural, time];
      [map setObject:result forKey:number];
    }
    return result;
  }
}


+ (NSString*) yearsAgoString:(NSInteger) year {
  return [self agoString:year
                     map:yearsAgoMap
                singular:LocalizedString(@"1 year ago", nil)
                  plural:LocalizedString(@"%d years ago", nil)];
}


+ (NSString*) monthsAgoString:(NSInteger) month {
  return [self agoString:month
                     map:monthsAgoMap
                singular:LocalizedString(@"1 month ago", nil)
                  plural:LocalizedString(@"%d months ago", nil)];
}


+ (NSString*) weeksAgoString:(NSInteger) week {
  return [self agoString:week
                     map:weeksAgoMap
                singular:LocalizedString(@"1 week ago", nil)
                  plural:LocalizedString(@"%d weeks ago", nil)];
}


+ (NSString*) timeSinceNowWorker:(NSDate*) date {
  NSTimeInterval interval = [today timeIntervalSinceDate:date];
  if (interval > ONE_YEAR) {
    return [self yearsAgoString:(NSInteger)(interval / ONE_YEAR)];
  } else if (interval > ONE_MONTH) {
    return [self monthsAgoString:(NSInteger)(interval / ONE_MONTH)];
  } else if (interval > ONE_WEEK) {
    return [self weeksAgoString:(NSInteger)(interval / ONE_WEEK)];
  }

  NSCalendar* calendar = [NSCalendar currentCalendar];
  NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit)
                                             fromDate:date
                                               toDate:today
                                              options:0];

  if (components.day == 0) {
    return LocalizedString(@"Today", nil);
  } else if (components.day == 1) {
    return LocalizedString(@"Yesterday", nil);
  } else {
    NSDateComponents* components2 = [calendar components:NSWeekdayCalendarUnit fromDate:date];

    NSInteger weekday = components2.weekday;
    switch (weekday) {
      case 1: return LocalizedString(@"Last Sunday", nil);
      case 2: return LocalizedString(@"Last Monday", nil);
      case 3: return LocalizedString(@"Last Tuesday", nil);
      case 4: return LocalizedString(@"Last Wednesday", nil);
      case 5: return LocalizedString(@"Last Thursday", nil);
      case 6: return LocalizedString(@"Last Friday", nil);
      default: return LocalizedString(@"Last Saturday", nil);
    }
  }
}


+ (NSString*) timeSinceNow:(NSDate*) date {
  NSString* result = nil;
  [gate lock];
  {
    result = [timeDifferenceMap objectForKey:date];
    if (result == nil) {
      result = [self timeSinceNowWorker:date];
      [timeDifferenceMap setObject:result forKey:date];
    }
  }
  [gate unlock];
  return result;
}


+ (NSDate*) today {
  return today;
}


+ (NSDate*) tomorrow {
  NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
  components.day = 1;

  return [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                       toDate:today
                                                      options:0];
}


+ (BOOL) isSameDay:(NSDate*) d1
              date:(NSDate*) d2 {
  NSCalendar* calendar = [NSCalendar currentCalendar];
  NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                              fromDate:d1];
  NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                              fromDate:d2];

  return
  [components1 year] == [components2 year] &&
  [components1 month] == [components2 month] &&
  [components1 day] == [components2 day];
}


+ (BOOL) isToday:(NSDate*) date {
  return [DateUtilities isSameDay:today date:date];
}


+ (NSString*) format:(NSDate*) date formatter:(NSDateFormatter*) formatter {
  NSString* result;
  [gate lock];
  {
    result = [formatter stringFromDate:date];
  }
  [gate unlock];
  return result;
}


+ (NSString*) formatShortTimeWorker:(NSDate*) date {
  NSDateComponents* components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
                                             fromDate:date];

  if ([self use24HourTime]) {
    return [NSString stringWithFormat:@"%02d:%02d", components.hour, components.minute];
  } else {
    if (components.hour == 0) {
      return [NSString stringWithFormat:@"12:%02dam", components.minute];
    } else if (components.hour == 12) {
      return [NSString stringWithFormat:@"12:%02dpm", components.minute];
    } else if (components.hour > 12) {
      return [NSString stringWithFormat:@"%d:%02dpm", components.hour - 12, components.minute];
    } else {
      return [NSString stringWithFormat:@"%d:%02dam", components.hour, components.minute];
    }
  }
}


+ (NSString*) formatShortTime:(NSDate*) date {
  NSString* result;
  [gate lock];
  {
    result = [self formatShortTimeWorker:date];
  }
  [gate unlock];
  return result;
}


+ (NSString*) formatMediumDate:(NSDate*) date {
  return [self format:date formatter:mediumDateFormatter];
}


+ (NSString*) formatShortDate:(NSDate*) date {
  return [self format:date formatter:shortDateFormatter];
}


+ (NSString*) formatLongDate:(NSDate*) date {
  return [self format:date formatter:longDateFormatter];
}


+ (NSString*) formatFullDate:(NSDate*) date {
  return [self format:date formatter:fullDateFormatter];
}


+ (NSString*) formatYear:(NSDate*) date {
  return [self format:date formatter:yearFormatter];
}


+ (NSDate*) dateWithNaturalLanguageString:(NSString*) string {
  //return nil;
  return [(id)[NSDate class] dateWithNaturalLanguageString:string];
}


+ (NSDate*) parseISO8601DateWorker:(NSString*) string {
  if (string.length == 10) {
    NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
    components.year = [[string substringWithRange:NSMakeRange(0, 4)] integerValue];
    components.month = [[string substringWithRange:NSMakeRange(5, 2)] integerValue];
    components.day = [[string substringWithRange:NSMakeRange(8, 2)] integerValue];

    return [[NSCalendar currentCalendar] dateFromComponents:components];
  }

  return nil;
}


+ (NSDate*) parseISO8601Date:(NSString*) string {
  NSDate* result;
  [gate lock];
  {
    result = [iso8601Map objectForKey:string];
    if (result == nil) {
      result = [self parseISO8601DateWorker:string];
      if (result != nil) {
        [iso8601Map setObject:result forKey:string];
      }
    }
  }
  [gate unlock];
  return result;
}


+ (BOOL) use24HourTime {
  return use24HourTime;
}


+ (NSDate*) currentTimeWorker {
  return [calendar dateFromComponents:[calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit
                                                  fromDate:[NSDate date]]];
}


+ (NSDate*) currentTime {
  NSDate* result;
  [gate lock];
  {
    result = [self currentTimeWorker];
  }
  [gate unlock];
  return result;
}

@end
