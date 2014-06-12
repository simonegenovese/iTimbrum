//
//  ViewController.h
//  timbrum
//
//  Created by Simone Genovese on 03/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import "ZucchettiConnector.h"
// Import GADBannerView's definition from the SDK
#import "GADBannerView.h"
#import <CoreLocation/CoreLocation.h>

#endif
@class ZucchettiConnector;
@interface ViewController : UIViewController<CLLocationManagerDelegate>{
    GADBannerView *bannerView_;
    UILocalNotification* workFinishedNotif;
    CLLocationManager *manager;
    CLLocationDistance accuracy;
    CLRegion *regionCourante;
    CLLocationCoordinate2D centre;
}

@property (readwrite) NSDate * dataUscitaPranzo;
@property (readwrite) ZucchettiConnector *connecctor;
@property (readwrite) NSTimer *timer;
@property (retain) NSString * durataPranzo;
@property (strong, nonatomic) CLLocationManager *manager;
@property CLLocationDistance accuracy;
@property (strong, nonatomic) CLRegion *regionCourante;
@property CLLocationCoordinate2D centre;

-(void) loadHTML:(NSString *) data;

-(void) loadNewDataList:(NSArray*) array;
@end
