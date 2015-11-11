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
#import <CoreLocation/CoreLocation.h>
#include "VerificaTimbratura.h"
#include "Reachability.h"
#endif

@class ZucchettiConnector;
@interface ViewController : UIViewController<CLLocationManagerDelegate>{
    UILocalNotification* workFinishedNotif;
    CLLocationManager *manager;
    CLLocationDistance accuracy;
    CLRegion *regionCourante;
    CLLocationCoordinate2D centre;
    BOOL isLastAnEnter;
    BOOL isAtWork;
    // declare Reachability, you no longer have a singleton but manage instances
    Reachability* reach;
}

@property (readwrite) NSDate * dataUscitaPranzo;
@property (readwrite) ZucchettiConnector *connector;
@property (readwrite) NSTimer *timer;
@property (retain) NSString * durataPranzo;
@property (strong, nonatomic) CLLocationManager *manager;
@property CLLocationDistance accuracy;
@property(strong, nonatomic) Reachability* reach;

@property (strong, nonatomic) CLRegion *regionCourante;
@property CLLocationCoordinate2D centre;

-(void) loadHTML:(NSString *) data;

-(void) loadNewDataList:(NSArray*) array;
@end
