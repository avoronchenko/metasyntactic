//
//  FandangoTheaterDownloader.m
//  BoxOffice
//
//  Created by Cyrus Najmabadi on 5/14/08.
//  Copyright 2008 Metasyntactic. All rights reserved.
//

#import "FandangoTheaterDownloader.h"

#import "XmlElement.h"
#import "Theater.h"
#import "XmlParser.h"
#import "Utilities.h"

@implementation FandangoTheaterDownloader

+ (NSDictionary*) processMoviesElement:(XmlElement*) moviesElement {
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    
    for (XmlElement* movieElement in moviesElement.children) {
        NSString* movieId = [movieElement attributeValue:@"id"];
        NSString* title = [[movieElement element:@"title"] text];

        if (movieId != nil && title != nil) {
            [result setObject:title forKey:movieId];
        }
    }

    return result;
}

+ (NSArray*) processTheatersElement:(XmlElement*) theatersElement
                            withMap:movieIdToTitleMap {
    NSMutableArray* array = [NSMutableArray array];

    for (XmlElement* theaterElement in theatersElement.children) {
        NSString* name = [[theaterElement element:@"name"] text];
        NSString* address = [NSString stringWithFormat:@"%@, %@, %@ %@",
                             [[theaterElement element:@"address1"] text],
                             [[theaterElement element:@"city"] text],
                             [[theaterElement element:@"state"] text],
                             [[theaterElement element:@"postalcode"] text]];
        NSString* phoneNumber = [[theaterElement element:@"phonenumber"] text];
        
        NSMutableDictionary* movieToShowtimesMap = [NSMutableDictionary dictionary];
        
        XmlElement* moviesElement = [theaterElement element:@"movies"];
        for (XmlElement* movieElement in moviesElement.children) {
            NSString* title = [movieIdToTitleMap objectForKey:[movieElement attributeValue:@"id"]];
            NSMutableArray* showtimes = [NSMutableArray array];
            
            XmlElement* performancesElement = [movieElement element:@"performances"];
            for (XmlElement* performanceElement in performancesElement.children) {
                NSString* showtime = [performanceElement attributeValue:@"showtime"];
                showtime = [Theater processShowtime:showtime];
                [showtimes addObject:showtime];
            }
            
            [movieToShowtimesMap setObject:showtimes forKey:title];
        }
        
        if ([movieToShowtimesMap count] == 0) {
            continue;
        }
        
        NSDictionary* preparedShowtimes = [Theater prepareShowtimesMap:movieToShowtimesMap];
        Theater* theater = [Theater theaterWithName:name
                                            address:address
                                        phoneNumber:phoneNumber
                                movieToShowtimesMap:preparedShowtimes];
        
        [array addObject:theater];
    }
    
    return array;
}

+ (NSArray*) download:(NSString*) zipcode {
    NSString* urlString = [NSString stringWithFormat:@"http://www.fandango.com/frdi/?pid=A99D3D1A-774C-49149E&op=performancesbypostalcodesearch&verbosity=1&postalcode=%@", zipcode];

    XmlElement* performanceElement = [Utilities downloadXml:urlString];
    
    if (performanceElement != nil) {
        XmlElement* dataElement = [performanceElement element:@"data"];
        XmlElement* theatersElement = [dataElement element:@"theaters"];
        XmlElement* moviesElement = [dataElement element:@"movies"];
        
        if (theatersElement != nil && moviesElement != nil) {
            NSDictionary* movieIdToNameMap = [self processMoviesElement:moviesElement];
            return [self processTheatersElement:theatersElement withMap:movieIdToNameMap];
        }
    }    
    
    return nil;    
}

@end
