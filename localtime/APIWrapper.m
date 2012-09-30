//
//  APIWrapper.m
//  localtime
//
//  Created by Jeff Grimes on 9/29/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import "APIWrapper.h"

// authentication for AskGeo endpoint
const NSString *askGeoUserId = @"469";
const NSString *askGeoSecret = @"ca573f36bc428c2355bc986504443ea9575dd04e214aa915267e534570b9b8a3";

@implementation APIWrapper

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"connection error.");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    id jsonObjects = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        [self performSelector:self.failureSelector];
        return;
    }
    
    // check if response is an array vs. dict
    if ([jsonObjects isKindOfClass:[NSArray class]]) {
        self.responseArray = [[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i < [jsonObjects count]; i++) {
            [self.responseArray addObject:[jsonObjects objectAtIndex:i]];
        }
    } else {
        NSArray *keys = [jsonObjects allKeys];
        NSMutableArray *values = [[NSMutableArray alloc] init];
        for (NSString *key in keys) {
            [values addObject:[jsonObjects objectForKey:key]];
        }
        self.responseDict = [[[NSDictionary alloc] initWithObjects:values forKeys:keys] autorelease];
        [values release];
    }
    
    [self performSelector:self.successSelector];
}


- (void)getTimezoneForLat:(float)lat andLon:(float)lon {
    // fetch timezone from AskGeo
    self.successSelector = @selector(callGotTimezone);
    self.failureSelector = @selector(callGotTimezoneError);
    
    self.responseData = [[NSMutableData data] retain];
    NSString *urlString = [[NSString stringWithFormat:@"http://api.askgeo.com/v1/%@/%@/query.json?points=%f,%f&databases=Point,TimeZone", askGeoUserId, askGeoSecret, lat, lon] stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

- (void)callGotTimezone {
    if ([self.timezoneDelegate respondsToSelector:@selector(gotTimezone)]) {
        [self.timezoneDelegate gotTimezone];
    } else {
        NSLog(@"timezoneDelegate does not implement gotTimezone.");
    }
}

- (void)callGotTimezoneError {
    if ([self.timezoneDelegate respondsToSelector:@selector(gotTimezoneError)]) {
        [self.timezoneDelegate gotTimezoneError];
    } else {
        NSLog(@"timezoneDelegate does not implement gotTimezoneError.");
    }
}

- (void)dealloc {
    self.responseData = nil;
    self.responseDict = nil;
    self.responseArray = nil;
    self.timezoneDelegate = nil;
    [super dealloc];
}

@end