//
//  ViewController.m
//  localtime
//
//  Created by Jeff Grimes on 9/29/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign) CGPoint touchPoint;

@end

const int popupTag = 1000;
const int textTag = 1001;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.apiWrapper = [[[APIWrapper alloc] init] autorelease];
    self.apiWrapper.timezoneDelegate = self;
    
    UITapGestureRecognizer* mapTapper = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(mapTapped:)];
    [self.mapView addGestureRecognizer:mapTapper];
    [mapTapper release];
}

- (IBAction)mapTapped:(id)sender {
    // user touched the map
    [self.spinner startAnimating];
    CGPoint point = [sender locationInView:self.mapView];
    self.touchPoint = point;
    CLLocationCoordinate2D pointCoord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    float lat = pointCoord.latitude;
    float lon = pointCoord.longitude;
    [self.apiWrapper getTimezoneForLat:lat andLon:lon];
}

- (void)showPopupWithString:(NSString *)string {
    float stubRatio = 0.24; // what fraction of the popup's height is the triangular stub
    float popupWidthToHeight = 2; // popup's ratio of width to height
    float vertPadding = 3; // vertical padding for text in popup
    float horiPadding = 3; // horizontal padding for text in popup
    
    int popupHeight = 36; // desired height of text popup
    int popupWidth = popupHeight * popupWidthToHeight;
    int headerHeight = self.whiteHeader.frame.size.height;
    
    UIImage *popupImage;
    UIImageView *popup;
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.tag = textTag;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont fontWithName:@"Gill Sans" size:16];
    textLabel.text = string;
    
    float stubOffset = popupHeight*stubRatio + vertPadding;
    float width = popupWidth - 2*horiPadding;
    float height = popupHeight - stubOffset - vertPadding;
    
    if (self.touchPoint.y < headerHeight) {
        return;
    } else if (self.touchPoint.y < headerHeight + popupHeight) {
        popupImage = [UIImage imageNamed:@"test2.png"];
        popup = [[UIImageView alloc] initWithImage:popupImage];
        popup.frame = CGRectMake(self.touchPoint.x - popupWidth/2, self.touchPoint.y, popupWidth, popupHeight);
        textLabel.frame = CGRectMake(popup.frame.origin.x + horiPadding, popup.frame.origin.y + stubOffset, width, height);
    } else {
        popupImage = [UIImage imageNamed:@"test.png"];
        popup = [[UIImageView alloc] initWithImage:popupImage];
        popup.frame = CGRectMake(self.touchPoint.x - popupWidth/2, self.touchPoint.y - popupHeight, popupWidth, popupHeight);
        textLabel.frame = CGRectMake(popup.frame.origin.x + horiPadding, popup.frame.origin.y + vertPadding, width, height);
    }
    popup.tag = popupTag;
    
    [[self.view viewWithTag:popupTag] removeFromSuperview];
    [[self.view viewWithTag:textTag] removeFromSuperview];
    [self.view addSubview:popup];
    [self.view addSubview:textLabel];
    [popup release];
    [textLabel release];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    // user started a double-click, swipe, or pinch
    [[self.view viewWithTag:popupTag] removeFromSuperview];
    [[self.view viewWithTag:textTag] removeFromSuperview];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    // user ended a double-click, swipe, or pinch
    float lat = self.mapView.region.center.latitude;
    float lon = self.mapView.region.center.longitude;
    self.centerCoordinatesLabel.text = [NSString stringWithFormat:@"Center Coordinates: (%.2f, %.2f)", lat, lon];
}

- (void)gotTimezone {
    // get the timezone from the api response
    [self.spinner stopAnimating];
    NSString *timezoneName = [[[[self.apiWrapper.responseDict objectForKey:@"data"] objectAtIndex:0] objectForKey:@"TimeZone"] objectForKey:@"TimeZoneId"];
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:timezoneName];
    
    // format the time and set it to the time in the fetched timezone
    NSDateFormatter *localTimeFormat = [[NSDateFormatter alloc] init];
    [localTimeFormat setTimeZone:timezone];
    [localTimeFormat setDateFormat:@"h:mm a"];
    NSDate *localTime = [[NSDate alloc] init];
    NSString *localTimeString = [localTimeFormat stringFromDate:localTime];
    [localTimeFormat release];
    [localTime release];
    [self showPopupWithString:localTimeString];
}

- (void)gotTimezoneError {
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"" message:@"Could not get local time." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil] autorelease];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    self.apiWrapper = nil;
    self.mapView = nil;
    self.centerCoordinatesLabel = nil;
    self.whiteHeader = nil;
    [super dealloc];
}

@end