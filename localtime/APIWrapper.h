//
//  APIWrapper.h
//  localtime
//
//  Created by Jeff Grimes on 9/29/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimezoneProtocol <NSObject>
- (void)gotTimezone;
- (void)gotTimezoneError;
@end

@interface APIWrapper : NSObject

@property (nonatomic, assign) id <TimezoneProtocol> timezoneDelegate;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) NSDictionary *responseDict;
@property (nonatomic, retain) NSMutableArray *responseArray;
@property (nonatomic, assign) SEL successSelector;
@property (nonatomic, assign) SEL failureSelector;

- (void)getTimezoneForLat:(float)lat andLon:(float)lon;

@end