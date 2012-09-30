//
//  ViewController.h
//  localtime
//
//  Created by Jeff Grimes on 9/29/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "APIWrapper.h"

@interface ViewController : UIViewController <MKMapViewDelegate, TimezoneProtocol>

@property (nonatomic, retain) APIWrapper *apiWrapper;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UILabel *centerCoordinatesLabel;
@property (nonatomic, retain) IBOutlet UIImageView *whiteHeader;

@end